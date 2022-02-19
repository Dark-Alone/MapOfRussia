//
//  Features+MapKit.swift
//  MapOfRussia
//
//  Created by Марк Акиваев on 2/19/22.
//

import Foundation
import MapKit

// MapKit extension
extension Features {
    static func makePolygon(from rawCoordinates: [[Double]]) -> MKPolygon? {
        var maxLongitude: Double = -190
        var minLongitude: Double = 400
        
        let coordinates = rawCoordinates.map { coordinate -> CLLocationCoordinate2D in
            let latitude = coordinate[1]
            let longitude = coordinate[0]
            
//            if longitude <= 0 {
//                // долгота: до меридиана(180) + после меридиана(переводим отрицательную долготу в положетельную) (180 + изначальные данные)
////                print("все по чесноку!")
//                longitude = 180 + longitude + 180
//            }
            
            if longitude > maxLongitude {
                maxLongitude = longitude
            }
            if longitude < minLongitude {
                minLongitude = longitude
            }
            
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        let difference = maxLongitude - minLongitude
        
        
//        if difference > 150 {
//            print("minLongitude: \(minLongitude)")
//            print("maxLongitude: \(maxLongitude)")
//            print("difference: \(difference)")
//        } else {
//            print("difference: \(difference)")
//        }
        print("maxLongitude: \(maxLongitude)")
        
        return MKPolygon(coordinates: coordinates, count: coordinates.count)
    }
    
    func generatePolygons() -> [[MKPolygon]] {
        return geometry.coordinates
            .map { coordinates -> [MKPolygon] in
                return coordinates
                    .compactMap { rawCoordinates -> MKPolygon? in
                        return Features.makePolygon(from: rawCoordinates)
                    }
            }
    }
    
    func generateMultiPolygons() -> [MKMultiPolygon] {
        return generatePolygons()
            .map { polygons in return MKMultiPolygon(polygons) }
    }
}


