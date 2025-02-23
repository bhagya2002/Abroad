//
//  MapView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-02.
//

import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var pins: [Pin]
    @Binding var selectedPin: Pin?
    @Binding var isEditingPin: Bool
    @Binding var disableAutoCenter: Bool

    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: MapView
        var pendingZoomWorkItem: DispatchWorkItem?
        
        let zoomedSpan = MKCoordinateSpan(latitudeDelta: 0.14, longitudeDelta: 0.14)
        let selectionPointThreshold: CGFloat = 20
        let coordinateThreshold = 0.0001
        
        init(parent: MapView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard let mapView = gestureRecognizer.view as? MKMapView else { return }
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            pendingZoomWorkItem?.cancel()
            
            if let existingPin = self.parent.pins.first(where: { pin in
                let pinPoint = mapView.convert(pin.coordinate, toPointTo: mapView)
                let distance = hypot(pinPoint.x - touchPoint.x, pinPoint.y - touchPoint.y)
                return distance < selectionPointThreshold
            }) {
                self.parent.disableAutoCenter = false
                
                DispatchQueue.main.async {
                    self.parent.region = MKCoordinateRegion(
                        center: existingPin.coordinate,
                        span: self.zoomedSpan
                    )
                    
                    let workItem = DispatchWorkItem {
                        self.parent.selectedPin = existingPin
                        self.parent.isEditingPin = true
                    }
                    self.pendingZoomWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
                }
                return
            }
            
            DispatchQueue.main.async {
                let newPin = Pin(title: "", coordinate: coordinate, category: .visited)
                self.parent.pins.append(newPin)
                self.parent.selectedPin = newPin
                self.parent.isEditingPin = true
                self.parent.disableAutoCenter = false
                self.parent.region = MKCoordinateRegion(center: coordinate, span: self.zoomedSpan)
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            guard let annotation = annotation as? MKPointAnnotation else { return }
            
            pendingZoomWorkItem?.cancel()
            
            if let pin = parent.pins.first(where: {
                abs($0.coordinate.latitude - annotation.coordinate.latitude) < coordinateThreshold &&
                abs($0.coordinate.longitude - annotation.coordinate.longitude) < coordinateThreshold
            }) {
                self.parent.disableAutoCenter = false
                
                DispatchQueue.main.async {
                    self.parent.region = MKCoordinateRegion(
                        center: pin.coordinate,
                        span: self.zoomedSpan
                    )
                    
                    let workItem = DispatchWorkItem {
                        self.parent.selectedPin = pin
                        self.parent.isEditingPin = true
                    }
                    self.pendingZoomWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
                }
            }
            
            mapView.deselectAnnotation(annotation, animated: false)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? MKPointAnnotation else { return nil }
            
            let identifier = "pin"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if view == nil {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view?.canShowCallout = true
            } else {
                view?.annotation = annotation
            }
            
            if let pin = parent.pins.first(where: {
                abs($0.coordinate.latitude - annotation.coordinate.latitude) < coordinateThreshold &&
                abs($0.coordinate.longitude - annotation.coordinate.longitude) < coordinateThreshold
            }) {
                view?.markerTintColor = pin.category == .visited ? .red : .blue
            }
            
            return view
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.region = region
        mapView.delegate = context.coordinator
        
        mapView.overrideUserInterfaceStyle = .dark
        mapView.mapType = .mutedStandard
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if uiView.annotations.count != pins.count {
            uiView.removeAnnotations(uiView.annotations)
            let annotations = pins.map { pin -> MKPointAnnotation in
                let annotation = MKPointAnnotation()
                annotation.coordinate = pin.coordinate
                annotation.title = pin.title
                return annotation
            }
            uiView.addAnnotations(annotations)
        } else {
            for annotation in uiView.annotations {
                if let pointAnnotation = annotation as? MKPointAnnotation,
                   let annotationView = uiView.view(for: pointAnnotation) as? MKMarkerAnnotationView,
                   let matchingPin = pins.first(where: {
                        abs($0.coordinate.latitude - pointAnnotation.coordinate.latitude) < context.coordinator.coordinateThreshold &&
                        abs($0.coordinate.longitude - pointAnnotation.coordinate.longitude) < context.coordinator.coordinateThreshold
                   }) {
                    annotationView.markerTintColor = matchingPin.category == .visited ? .red : .blue
                    pointAnnotation.title = matchingPin.title
                }
            }
        }
        
        if disableAutoCenter {
            uiView.selectedAnnotations.forEach { annotation in
                uiView.deselectAnnotation(annotation, animated: false)
            }
        }
        
        let targetCenter: CLLocationCoordinate2D = disableAutoCenter ? uiView.region.center : region.center
        let newRegion = MKCoordinateRegion(center: targetCenter, span: region.span)
        
        if abs(uiView.region.center.latitude - newRegion.center.latitude) > context.coordinator.coordinateThreshold ||
           abs(uiView.region.center.longitude - newRegion.center.longitude) > context.coordinator.coordinateThreshold ||
           abs(uiView.region.span.latitudeDelta - newRegion.span.latitudeDelta) > context.coordinator.coordinateThreshold ||
           abs(uiView.region.span.longitudeDelta - newRegion.span.longitudeDelta) > context.coordinator.coordinateThreshold {
            uiView.setRegion(newRegion, animated: true)
        }
    }
}
