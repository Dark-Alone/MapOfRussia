//
//  GoogleMapView.swift
//  MapOfRussia
//
//  Created by Марк Акиваев on 2/18/22.
//

import SwiftUI
import GoogleMaps


struct GoogleMapView: UIViewRepresentable {
    @Binding var features: Features?
    
    @Environment(\.colorScheme) var colorScheme
    
    // mapModel strores Polygones, selectedPolygone, tappedPoint
    @EnvironmentObject var mapModel: MapViewModel
    
    
    
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView()
        // coordinator with GMSMapViewDelegate
        mapView.delegate = context.coordinator
        
        // Moving camera to center of Russia
        let camera = GMSCameraPosition.camera(withLatitude: 58.60945134188946, longitude: 44.77115694433451, zoom: 4)
        mapView.camera = camera
        
        // Support dark theme *on launch
        if colorScheme == .dark {
            guard let mapStyleURL = Bundle.main.url(forResource: "Dark", withExtension: "json") else { fatalError("There no Dark.json file in bundle") }
            mapView.mapStyle = try? GMSMapStyle(contentsOfFileURL: mapStyleURL)
        } else {
            mapView.mapStyle = nil
        }
        
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // generates polygons when features loaded from json
        guard let features = features else { return }
        
        // preventing generate new polygons
        // TODO: Update for MVVM
        if !mapModel.wasDrawed {
            print("generate paths")
            features.generatePaths()
                .forEach { path in
                    let polygon = GMSPolygon(path: path)
                    polygon.strokeColor = UIColor(named: "StrokeColor")
                    polygon.fillColor = UIColor(named: "FillColor")
                    polygon.map = uiView
                    
                    polygon.isTappable = true

                    mapModel.polygons.append(polygon)
                }
            
            mapModel.wasDrawed = true
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator for handle tap on polygone
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView
        
        // calls when tap outside of polygons
        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            print("tap at \(coordinate)")
            parent.mapModel.selectPosition(position: coordinate)
            parent.mapModel.deselectPolygon()
        }
        
        func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
            if let polygon = overlay as? GMSPolygon {
                // TODO: Notification with location length
                self.parent.mapModel.selectPolygon(polygon: polygon)
            }
            
            print("tap")
        }
        
        init(_ parent: GoogleMapView) {
            self.parent = parent
        }
    }
}
