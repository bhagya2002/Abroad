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

            // Define a more precise selection threshold
            let selectionThreshold: Double = 0.0005 // More precise threshold

            // Check if a pin exists at the tapped location
            if let existingPin = self.parent.pins.first(where: { pin in
                let distance = hypot(pin.coordinate.latitude - coordinate.latitude,
                                     pin.coordinate.longitude - coordinate.longitude)
                return distance < selectionThreshold
            }) {
                DispatchQueue.main.async {
                    self.parent.selectedPin = existingPin
                    self.parent.isEditingPin = true
                }
                return // Stop execution to prevent new pin creation
            }

            // If no existing pin was found, create a new one
            DispatchQueue.main.async {
                let newPin = Pin(title: "", coordinate: coordinate, category: .visited)
                self.parent.pins.append(newPin)
                self.parent.selectedPin = newPin
                self.parent.isEditingPin = true
            }
        }

        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            guard let annotation = annotation as? MKPointAnnotation else { return }

            if let pin = parent.pins.first(where: {
                $0.coordinate.latitude == annotation.coordinate.latitude &&
                $0.coordinate.longitude == annotation.coordinate.longitude
            }) {
                DispatchQueue.main.async {
                    let currentZoom = self.parent.region.span.latitudeDelta

                    if self.parent.selectedPin == pin {
                        if currentZoom < 0.1 {
                            self.parent.isEditingPin = true
                        } else {
                            self.parent.isEditingPin = false
                        }
                    } else {
                        self.parent.selectedPin = pin
                        self.parent.region = MKCoordinateRegion(
                            center: pin.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
                        )
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

        // Update the visible region
        if uiView.region.center.latitude != region.center.latitude ||
            uiView.region.center.longitude != region.center.longitude {
            uiView.setRegion(region, animated: true)
        }
    }

}

