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
    var textOverlay: GMSGroundOverlay?
    
    // variable to prevent generating new polygons when view updates
    @Published var wasDrawed = false
    
    // Performs when tap on new polygone
    func selectPolygon(polygon: GMSPolygon) {
        deselectPolygon()
        polygon.fillColor = UIColor(named: "SelectedFillColor")
        selectedPolygon = polygon
    }

    // Performs when tap outside old polygone
    func deselectPolygon() {
        selectedPolygon?.fillColor = UIColor(named: "FillColor")
        selectedPolygon = nil
    }
    
    // Function to provide only one label of text overlay
    func newTextOverlay(new: GMSGroundOverlay) {
        self.textOverlay?.map = nil
        textOverlay = new
    }
}
