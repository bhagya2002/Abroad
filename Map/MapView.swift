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

        init(parent: MapView) {
            self.parent = parent
        }

        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let mapView = gestureRecognizer.view as! MKMapView
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

            // Dynamic tap selection threshold based on zoom level
            let zoomLevel = parent.region.span.latitudeDelta
            let selectionThreshold = zoomLevel * 0.02 // Adjust threshold dynamically

            if let existingPin = parent.pins.first(where: { pin in
                let distance = hypot(pin.coordinate.latitude - coordinate.latitude,
                                     pin.coordinate.longitude - coordinate.longitude)
                return distance < selectionThreshold
            }) {
                DispatchQueue.main.async {
                    self.parent.selectedPin = existingPin
                    self.parent.isEditingPin = true
                }
                return
            }

            DispatchQueue.main.async {
                let newPin = Pin(title: "", coordinate: coordinate, category: .visited)

                print("New pin created: \(newPin.title) at \(newPin.coordinate)")

                self.parent.pins.append(newPin)

                // ✅ Set selectedPin immediately before opening the edit view
                self.parent.selectedPin = newPin
                self.parent.isEditingPin = true
                
                print("selectedPin set: \(self.parent.selectedPin?.title ?? "None")")
            }
        }

        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            if let annotation = annotation as? MKPointAnnotation {
                if let pin = parent.pins.first(where: { $0.coordinate.latitude == annotation.coordinate.latitude && $0.coordinate.longitude == annotation.coordinate.longitude }) {
                    DispatchQueue.main.async {
                        self.parent.selectedPin = pin
                        self.parent.isEditingPin = true
                    }
                }
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

            // Set pin color based on category
            if let pin = parent.pins.first(where: { $0.coordinate.latitude == annotation.coordinate.latitude && $0.coordinate.longitude == annotation.coordinate.longitude }) {
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
        uiView.removeAnnotations(uiView.annotations) // Remove existing annotations
        let annotations = pins.map { pin -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinate
            annotation.title = pin.title
            return annotation
        }
        uiView.addAnnotations(annotations)
    }
}

