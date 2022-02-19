//
//  Geometry+GoogleMaps.swift
//  MapOfRussia
//
//  Created by Марк Акиваев on 2/19/22.
//

import SwiftUI
import GoogleMaps

// Google Maps extension
extension Features {
    
    func generatePaths() -> [GMSPath] {
        // polygons coordinates
        let polygonsCoordinates = self.geometry.coordinates.map { coordinates in
            // coordinates used to draw polygons
            return coordinates
                .map { rawCoordinates -> [CLLocationCoordinate2D] in
                    // make from rawcoordinates CLLocatinCoordinate2D
                    return rawCoordinates.map { CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0])}
                }
        }
        
        var paths = [GMSPath]()
        print(polygonsCoordinates.count)
        // create paths
        for i in 0..<polygonsCoordinates.count {
            // for prevent repeat same code
            let path = GMSMutablePath()
            
            print("index: \(i)")
            if i == 67 || i == 91 {
                // пропускаем, потому что массивы с индексами 67 и 91 будут соединены с массивами индексов 159 и 93 соответственно
                // для правильной отрисовки за 180 меридианом
                print("skip")
                continue
            } else if i == 93 {
                // TODO: добавляем к 93 91
                // состыковка 71.53668798799998 64 93 (вырезая 62, 63)
                // состыковка 71.517523505 56 91 (вырезая 0, 1)
                // вырезаем координаты, чтобы не было линии посередине острова Врангеля
                
                // получаем координаты для дальнейших преобразований
                let rawCoordinates93 = polygonsCoordinates[93][0]
                let rawCoordinates91 = polygonsCoordinates[91][0]
                
                let count93 = rawCoordinates93.count
                let count91 = rawCoordinates91.count
                
                let coordinates93 = rawCoordinates93[64..<count93] + rawCoordinates93[0..<61]
                let coordinates91 = rawCoordinates91[2..<56]  + rawCoordinates91[56..<count91]
                
                let concatinatedCoordinates = coordinates93 + coordinates91
                
                for coordinate in concatinatedCoordinates {
                    path.add(coordinate)
                }
            } else if i == 159 {
                // TODO: добавляем к 159 67
                // аналогично состыковка и вырез
                let rawCoordinates67 = polygonsCoordinates[67][0]
                let rawCoordinates159 = polygonsCoordinates[159][0]
                
                let count67 = rawCoordinates67.count
                let count159 = rawCoordinates159.count
            
                // вырезаем 1307...1309
                let coordinates67 = rawCoordinates67[0..<1301] + rawCoordinates67[1301..<1306] + rawCoordinates67[1310..<count67]
                
                // тест состыковки в 3620, вырезаем 3621...3623
                let coordinates159 = rawCoordinates159[3624..<count159] + rawCoordinates159[0..<3604] + rawCoordinates159[3604..<3620]
                
                let concatinatedCoordinates = coordinates67 + coordinates159
                
                for coordinate in concatinatedCoordinates {
                    path.add(coordinate)
                }
                
                print("count159 \(count159)")
                print("count67  \(count67)")
            } else {
                for polygonCoordinates in polygonsCoordinates[i][0] {
                    path.add(polygonCoordinates)
                }
            }
            
            paths.append(GMSPath(path: path))
        }
        
        return paths
    }
}
