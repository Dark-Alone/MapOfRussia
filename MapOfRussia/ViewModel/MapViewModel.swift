//
//  Fetcher.swift
//  MapOfRussia
//
//  Created by Марк Акиваев on 2/18/22.
//

import SwiftUI
import GoogleMaps

class MapViewModel: ObservableObject {
    var polylines = [GMSPolyline]()
    var polygons = [GMSPolygon]()
    
    @Published var selectedPolygon: GMSPolygon?
    @Published var selectedPosition: CLLocationCoordinate2D?
//    var textOverlay: GMSGroundOverlay?
    
    // variable to prevent generating new polygons when view updates
    @Published var wasDrawed = false
    
    // variable for animation border length overlay
    var isSelectedPolygon: Bool {
        // if polygon and path exists -> showing overlay
        guard let _ = selectedPolygon?.path else { return false }
        
        // if selectedPosition exists -> not showing overlay
        guard let _ = selectedPosition else {
            print("selected position not exists")
            return true
        }

        return false
    }
    
    // Performs when tap on new polygone
    func selectPolygon(polygon: GMSPolygon) {
        deselectPolygon()
        polygon.fillColor = UIColor(named: "SelectedFillColor")
        selectedPolygon = polygon
        // deselect position for selectedPositionInSelectedPolygon
        selectedPosition = nil
    }

    // Performs when tap outside old polygone
    func deselectPolygon() {
        selectedPolygon?.fillColor = UIColor(named: "FillColor")
        selectedPolygon = nil
    }
    
    // calculation every time when selected polygon changes
    func calculateBorderLength() -> String {
        guard let selectedPolygon = selectedPolygon else { return "" }
        
        guard let path = selectedPolygon.path else { return "" }
        
        let length = path.length(of: .geodesic).binade
        
        let km = Int(length) / 1000
        let m = Int(length - Double(km) * 1000)
        
        let text = "Border size" + (km > 0 ? " \(km)km" : "") + (m > 0 ? " \(m)m" : "")
        
        return text
    }
}
