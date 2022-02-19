//
//  MapView.swift
//  MapOfRussia
//
//  Created by Марк Акиваев on 2/18/22.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var features: Features?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // update when drawBorder is true or when geometry had changed
        guard let features = features else { return }
        print("polygon draw")
        
        let polygons = features.generatePolygons()
        print("polygons count: \(polygons.count)")
        features.generateMultiPolygons().forEach { multiPolygon in
            uiView.addOverlay(multiPolygon)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                print("polyline renderer")
                let polylineRenderer = MKPolylineRenderer(overlay: polyline)
                polylineRenderer.strokeColor = UIColor(named: "BorderColor")
                polylineRenderer.lineWidth = 3
                
                return polylineRenderer
            }
            
            if let multiPolygon = overlay as? MKMultiPolygon {
                let polygonRenderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon)
                polygonRenderer.strokeColor = UIColor(named: "BorderColor")
                polygonRenderer.lineWidth = 2
                
//                print("multipolygon renderer")
                return polygonRenderer
            }
            
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// MARK: - With polylines
//        if drawBorder {
//            print("drawBorder")
//            guard let rawCoordinates =  else { return }
//
//
//            for borderCoordinates in rawCoordinates.coordinates {
//                if let checkedBorderCoordinates = borderCoordinates.first {
//                    let coordinates: [CLLocationCoordinate2D] = checkedBorderCoordinates.compactMap { coordinateArray -> CLLocationCoordinate2D in
//                        return CLLocationCoordinate2D(latitude: coordinateArray[1], longitude: coordinateArray[0])
//                    }
//                    // create polyline from coordinates
//                    let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
//
//                    // draw polyline
//                    uiView.addOverlay(polyline)
//                }
//            }
//        }
