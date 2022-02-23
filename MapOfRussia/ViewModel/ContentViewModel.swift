//
//  ContentView-Model.swift
//  MapOfRussia
//
//  Created by Марк Акиваев on 2/23/22.
//

import SwiftUI

extension ContentView {
    class ContentViewModel: ObservableObject {
        // loading state for user understanding whats going on
        enum LoadingState {
            case loading
            case error
            case success
        }
        
        @Published var features: Features?
        @Published var loadingState: LoadingState = .loading
        
        @Published var successState: Bool = false
        
        
        // performs onAppear MapView inside ContentView
        func fetchData() {
            loadingState = .loading
            
            let urlString = "https://waadsu.com/api/russia.geo.json"
            guard let url = URL(string: urlString) else {
                print("url error")
                return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                print("data from urlsession")
                if let error = error {
                    self.loadingState = .error
                    print(error)
                }
                
                if let data = data {
                    let decoder = JSONDecoder()
                    
                    // without error -> pass
                    DispatchQueue.main.async {
                        do {
                            print("decoding data")
                            let decodedData = try decoder.decode(InputData.self, from: data)
                            // first
                            guard let features = decodedData.features.first else { return }
                            
                            self.features = features
                            self.loadingState = .success
                            
                            // make animation more controllable
                            withAnimation(.default.delay(3)) {
                                self.successState = true
                            }
                        } catch {
                            print("loading error")
                            print(error)
                            self.loadingState = .error
                        }
                    }
                }
            }.resume()
        }
    }
}
