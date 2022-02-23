//
//  Fetcher.swift
//  MapOfRussia
//
//  Created by Марк Акиваев on 2/18/22.
//

import SwiftUI
import GoogleMaps

class MapViewModel: ObservableObject {
    var polygons = [GMSPolygon]()
    
    @Published var selectedPolygon: GMSPolygon?
    @Published var selectedPosition: CLLocationCoordinate2D?
    
    // variable to prevent generating new polygons when view updates
    @Published var wasDrawed = false
    
    // variable for animation border length text overlay
    @Published var isPolygonSelected: Bool = false
    @Published var calculatedBorderLength = ""
    
    func selectPosition(position: CLLocationCoordinate2D) {
        self.selectedPosition = position
    }
    
    // Performs when tap on new polygone
    func selectPolygon(polygon: GMSPolygon) {
        deselectPolygon()
        polygon.fillColor = UIColor(named: "SelectedFillColor")
        selectedPolygon = polygon
        // deselect position for selectedPositionInSelectedPolygon
        selectedPosition = nil
        
        selectNewPolygon()
    }

    // Performs when tap outside old polygone
    func deselectPolygon() {
        selectedPolygon?.fillColor = UIColor(named: "FillColor")
        selectedPolygon = nil
        selectNewPolygon()
    }
    
    // calculation every time when selected polygon changes
    func calculateBorderLength() {
        guard let selectedPolygon = selectedPolygon else {
            calculatedBorderLength = ""
            return
        }
        
        guard let path = selectedPolygon.path else {
            calculatedBorderLength = ""
            return
        }
        
        let length = path.length(of: .geodesic).binade
        
        let km = Int(length) / 1000
        let m = Int(length - Double(km) * 1000)
        
        let text = "Border size" + (km > 0 ? " \(km)km" : "") + (m > 0 ? " \(m)m" : "")
        
        calculatedBorderLength = text
    }
    
    func selectNewPolygon() {
        // if polygon and path exists -> showing overlay
        guard let _ = selectedPolygon?.path else {
            self.isPolygonSelected = false
            return
        }
        
        // if selectedPosition exists -> not showing overlay
        guard let _ = selectedPosition else {
            print("selected position not exists")
            self.isPolygonSelected = true
            
            self.calculateBorderLength()
            return
        }

        self.isPolygonSelected = false
    }
}
