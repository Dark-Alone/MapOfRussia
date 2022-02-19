//
//  InputData.swift
//  MapOfRussia
//
//  Created by Марк Акиваев on 2/18/22.
//

import SwiftUI

// data specs
// len coordinates = 213 - all polylines
// len coordinates[] = 1 - buffer
// len coordinates[0][0] = 24 - Poligon coords
// len coordinates[][][] = 2 - long lat



// MARK: JSON decode helper
struct Geometry: Decodable {
    let type: String
    let coordinates: [[[[Double]]]]
}

struct Features: Decodable {
//    let type: String
    let geometry: Geometry
}

struct InputData: Decodable {
    let features: [Features]
}
