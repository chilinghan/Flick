//
//  ContentView.swift
//  WristPlus
//
//  Created by Ishani Chowdhury on 7/16/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.xyaxis.line")
                }
           /* ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                } */
        }
    }
}

#Preview {
    ContentView()
}

