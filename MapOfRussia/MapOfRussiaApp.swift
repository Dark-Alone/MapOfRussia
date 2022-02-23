//
//  MapOfRussiaApp.swift
//  MapOfRussia
//
//  Created by Марк Акиваев on 2/18/22.
//

import SwiftUI
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let apiKey = "AIzaSyBUFYagAPmPUS9aJGQKfwTxlQrsp1HR658"
        
        GMSServices.provideAPIKey(apiKey)
        
        return true
    }
}

@main
struct MapOfRussiaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
