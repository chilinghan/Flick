//
//  ContentView.swift
//  WristPlus
//
//  Created by Hunter T on 7/21/24.
//

import SwiftUI

struct ContentView: View {
    
    @State var accessorySessionManager = AccessorySessionManager()

    var body: some View {
        
//        PairedView(accessorySessionManager: accessorySessionManager)
        
        if accessorySessionManager.accessoryPaired {
            TabView {
                HomeView(accessorySessionManager: accessorySessionManager)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                StatsView(accessorySessionManager: accessorySessionManager)
                    .tabItem {
                        Label("Stats", systemImage: "chart.xyaxis.line")
                    }
                SettingsView(accessorySessionManager: accessorySessionManager)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                
            }
            .onAppear {
                Task {
                    while !accessorySessionManager.peripheralConnected {
                        accessorySessionManager.connect()
                        try await Task.sleep(nanoseconds: 200000000)
                    }
                }
            }
            
        } else {
            VStack {
                VStack {
                    Text("Flick")
                        .font(.system(size: 50, weight: .bold))                    .fontWeight(.bold)
                        .padding(.top, 20)
                }
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                Spacer(minLength: 20)

                
                Button {
                    accessorySessionManager.presentPicker()
                } label: {
                    Text("Pair")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, 28)
                .padding(.top, 20) // Add top padding to create some space between the image and the button
                                
                Spacer()
            }
        }
    }
}


#Preview {
    ContentView()
}
