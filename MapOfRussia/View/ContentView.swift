//
//  ContentView.swift
//  MapOfRussia
//
//  Created by Марк Акиваев on 2/18/22.
//

import SwiftUI

struct ContentView: View {
    @Namespace var animation
    
    // View Models
    @StateObject var viewModel = ContentViewModel()
    @StateObject var mapModel = MapViewModel()
    
    // TODO: Make matchedGeometryEffect animation correctly
    var body: some View {
        GoogleMapView(features: $viewModel.features)
            .ignoresSafeArea()
            .onAppear(perform: viewModel.fetchData)
        
            // Overlay for show loading state
            .overlay(
                ZStack {
                    switch viewModel.loadingState {
                    case .loading:
                        ProgressView()
                            .progressViewStyle(.circular)
                            .foregroundColor(.white)
                            .frame(width: 25, height: 25)
                            .matchedGeometryEffect(id: "textLoading", in: animation)
                    case .error:
                        VStack {
                            Text("Error")
                            
                            Button(action: viewModel.fetchData) {
                                Text("Try to reload")
                            }
                        }
                        .matchedGeometryEffect(id: "textLoading", in: animation)
                    case .success:
                        Text("Load success")
                            .matchedGeometryEffect(id: "textLoading", in: animation)
                    }
                }
               .foregroundColor(.white)
                // Custom View background
               .padding(5)
               .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(viewModel.successState ? Color("Success") : (viewModel.loadingState == .error ? Color.red : Color.purple))
                            .animation(.default, value: viewModel.successState)
                           
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(.white, lineWidth: 2)
                    }
                    .matchedGeometryEffect(id: "overlayBackground", in: animation)
                    .opacity(0.5)
               )
               .padding()
               // View with overlay opacity animation
                .opacity(viewModel.successState ? 0 : 1)
                // View with overlay resize animation
                .animation(.default, value: viewModel.loadingState),
                
                alignment: .bottomTrailing)
        
            // overlay polygon length
            .overlay(
                ZStack {
                    Text(mapModel.calculatedBorderLength)
                        .foregroundColor(.white)
                        .frame(width: 220)
                        .transition(.opacity)
                        .animation(.easeInOut, value: mapModel.calculatedBorderLength)
                        .animation(nil, value: mapModel.isPolygonSelected)
                        .padding(5)
                        .background(
                            ZStack {
                                Color.pink
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                        )
                        .padding()
                        .opacity(mapModel.isPolygonSelected ? 1 : 0)
                        // TODO: when polygon selected animation shows incorrect
                        .animation(.default, value: mapModel.isPolygonSelected)
                        .id("PolygonLengthText" + mapModel.calculatedBorderLength)
                },
                alignment: .bottom
            )
        
            .environmentObject(mapModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
