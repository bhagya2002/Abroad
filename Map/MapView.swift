//
//  MapView.swift
//  Abroad
//
//  Created by Bhagya Patel on 2025-02-02.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var pins: [Pin]
    @Binding var selectedPin: Pin?
    @Binding var isEditingPin: Bool

    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: MapView
        // Hold on to any pending work so it can be cancelled if a new tap occurs.
        var pendingZoomWorkItem: DispatchWorkItem?
        
        // Use a larger span so that the zoom is less aggressive.
        let zoomedSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        // Use a threshold in screen points.
        let selectionPointThreshold: CGFloat = 20
        // Threshold to compare coordinates (in degrees).
        let coordinateThreshold = 0.0001
        
        init(parent: MapView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard let mapView = gestureRecognizer.view as? MKMapView else { return }
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            // Cancel any pending zoom/edit action.
            pendingZoomWorkItem?.cancel()
            
            // Check for an existing pin near the tapped location by comparing screen points.
            if let existingPin = self.parent.pins.first(where: { pin in
                let pinPoint = mapView.convert(pin.coordinate, toPointTo: mapView)
                let distance = hypot(pinPoint.x - touchPoint.x, pinPoint.y - touchPoint.y)
                return distance < selectionPointThreshold
            }) {
                // If the tapped pin is not already centered, update the region.
                if abs(self.parent.region.center.latitude - existingPin.coordinate.latitude) > coordinateThreshold ||
                   abs(self.parent.region.center.longitude - existingPin.coordinate.longitude) > coordinateThreshold {
                    DispatchQueue.main.async {
                        self.parent.region = MKCoordinateRegion(
                            center: existingPin.coordinate,
                            span: self.zoomedSpan
                        )
                    }
                }
                // Schedule the edit view to open after a short delay.
                let workItem = DispatchWorkItem {
                    self.parent.selectedPin = existingPin
                    self.parent.isEditingPin = true
                }
                pendingZoomWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
                return // Stop here to prevent new pin creation.
            }
            
            // No existing pin nearby – create a new pin and open its edit view immediately.
            DispatchQueue.main.async {
                let newPin = Pin(title: "", coordinate: coordinate, category: .visited)
                self.parent.pins.append(newPin)
                self.parent.selectedPin = newPin
                self.parent.isEditingPin = true
            }
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            guard let annotation = annotation as? MKPointAnnotation else { return }
            
            // Cancel any pending zoom/edit action.
            pendingZoomWorkItem?.cancel()
            
            // Find the corresponding pin using a small threshold.
            if let pin = parent.pins.first(where: {
                abs($0.coordinate.latitude - annotation.coordinate.latitude) < coordinateThreshold &&
                abs($0.coordinate.longitude - annotation.coordinate.longitude) < coordinateThreshold
            }) {
                // Update the region if the new pin isn't already centered.
                if abs(self.parent.region.center.latitude - pin.coordinate.latitude) > coordinateThreshold ||
                   abs(self.parent.region.center.longitude - pin.coordinate.longitude) > coordinateThreshold {
                    DispatchQueue.main.async {
                        self.parent.region = MKCoordinateRegion(
                            center: pin.coordinate,
                            span: self.zoomedSpan
                        )
                    }
                }
                let workItem = DispatchWorkItem {
                    self.parent.selectedPin = pin
                    self.parent.isEditingPin = true
                }
                pendingZoomWorkItem = workItem
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
            }
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
            
            // Set the pin color based on its category.
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
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        let annotations = pins.map { pin -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = pin.title
            return annotation
        }
        uiView.addAnnotations(annotations)
        
        // Update the visible region if it has changed.
        if uiView.region.center.latitude != region.center.latitude ||
            uiView.region.center.longitude != region.center.longitude {
            uiView.setRegion(region, animated: true)
        }
    }
}
