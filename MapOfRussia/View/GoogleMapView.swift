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
    
    @StateObject var mapModel = MapViewModel()
    
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView()
        // coordinator with GMSMapViewDelegate
        mapView.delegate = context.coordinator
        
        // Support dark theme
        if colorScheme == .dark {
            print("change xd")
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
        if !mapModel.wasDrawed {
            print("generate paths")
            features.generatePaths()
                .forEach { path in
                    let polygon = GMSPolygon(path: path)
                    polygon.strokeColor = UIColor(named: "StrokeColor")
                    polygon.fillColor = UIColor(named: "FillColor")
                    polygon.map = uiView

                    mapModel.polygons.append(polygon)
                }
            
            mapModel.wasDrawed = true
        }
        
        // drawing text of border length of current tap position
        if let selectedPolygone = mapModel.selectedPolygon, let selectedPosition = mapModel.selectedPosition {
            // TODO: Make overlay always visible on tap
            print("draw overlay")
            // calculating border length km's and meters
            guard let path = selectedPolygone.path else { return }
            let polygonBorderLength = path.length(of: .geodesic).binade
            
            let km = Int(polygonBorderLength) / 1000
            let m = polygonBorderLength.binade - Double(km) * 1000
            
            // Generating image from text
            let text = "Border size" + (km > 0 ? " \(Int(km))km" : "") + (m > 0 ? String(format: " %.2fm", m) : "")
            guard let image = makeImageFromText(text: text, size: CGSize(width: 700, height: 33)) else { return }
            
            // Adding text overlay
            let textOverlay = GMSGroundOverlay(position: selectedPosition, icon: image, zoomLevel: 5)
            textOverlay.map = uiView
            
            mapModel.newTextOverlay(new: textOverlay)
        }
    }
    
    // Making border length text overlaying map
    func makeImageFromText(text: String, size: CGSize) -> UIImage? {
        let data = text.data(using: .utf8, allowLossyConversion: true)
        let drawText = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        
        // Shadow for text
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0.45, alpha: 0.9)
        shadow.shadowBlurRadius = 3
        
        let textAttributes: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 30, weight: .medium),
            .foregroundColor: UIColor.white,
            .shadow: shadow
        ]
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        drawText?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), withAttributes: textAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator for handle tap on polygone
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView
        
        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            var didSelected = false
            
            print("tap at \(coordinate)")
            
            for polygon in parent.mapModel.polygons {
                if GMSGeometryContainsLocation(coordinate, polygon.path!, true) {
                    didSelected = true
                    UIView.animate(withDuration: 0.5) {
                        self.parent.mapModel.selectPolygon(polygon: polygon)
                    }
                    
                    // For drawing border length on map (calls in updateUIView)
                    self.parent.mapModel.selectedPosition = coordinate
                    
                    
                    // for optimization purpose, leave loop
                    return
                }
            }
            
            if !didSelected {
                // TODO: StrokeColor + FillColor
                parent.mapModel.deselectPolygon()
            }
        }
        
        init(_ parent: GoogleMapView) {
            self.parent = parent
        }
    }
}
