//
//  ContentView.swift
//  MapOfRussia
//
//  Created by Марк Акиваев on 2/18/22.
//

import SwiftUI

struct ContentView: View {
    // loading state for user understanding whats going on
    enum LoadingState {
        case loading
        case error
        case success
    }
    
    @Namespace var animation
    
    @State var features: Features?
    @State var loadingState: LoadingState = .loading
    
    @State var successState: Bool = false
    
    var body: some View {
        GoogleMapView(features: $features)
            .ignoresSafeArea()
            .onAppear(perform: fetchData)
        
            // Overlay for show loading state
            .overlay(
                ZStack {
                    switch loadingState {
                    case .loading:
                        ProgressView()
                            .progressViewStyle(.circular)
                            .foregroundColor(.white)
                            .frame(width: 25, height: 25)
                    case .error:
                        VStack {
                            Text("Error")
                            
                            Button {
                                self.fetchData()
                            } label: {
                                Text("Try to reload")
                            }
                        }
                        
                    case .success:
                        Text("Load success")
                    }
                }
               .foregroundColor(.white)
                // Custom View background
               .padding(5)
               .background(
                   ZStack {
                       RoundedRectangle(cornerRadius: 5)
                           .fill(successState ? Color("Success") : (loadingState == .error ? Color.red : Color.purple))
                           .animation(.default, value: successState)
                           
                       RoundedRectangle(cornerRadius: 5)
                           .strokeBorder(.white, lineWidth: 2)
                   }
                       .opacity(0.3)
               )
               .padding()
               // View with overlay opacity animation
               .opacity(successState ? 0 : 1)
                // View with overlay resize animation
               .matchedGeometryEffect(id: "loadingView", in: animation)
               .animation(.default, value: loadingState),
                
                alignment: .bottomTrailing)
    }
    
    // performs onAppear MapView
    func fetchData() {
        let urlString = "https://waadsu.com/api/russia.geo.json"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                self.loadingState = .error
                print(error)
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                
                // without error -> pass
                DispatchQueue.main.async {
                    do {
                        let decodedData = try decoder.decode(InputData.self, from: data)
                        // first
                        guard let features = decodedData.features.first else { return }
                        
                        self.features = features
                        self.loadingState = .success
                        
                        // make animation more controllable
                        withAnimation(.default.delay(3).speed(0.3)) {
                            self.successState = true
                        }
                    } catch {
                        print(error)
                        self.loadingState = .error
                    }
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
