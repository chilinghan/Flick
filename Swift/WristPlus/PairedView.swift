//
//  PairedView.swift
//  sequoia
//
//  Created by Asteya Laxmanan on 7/14/24.
//

import Foundation
import SwiftUI

struct PairedView: View {
    let accessorySessionManager: AccessorySessionManager
    
    @AppStorage("accessoryPaired") private var accessoryPaired = false
    
    @State var isConnected = false
    @State var isHapticsOn = true
    @State var isTypingOn = false
        
    var body: some View {
//        TabView {
//            HomeView()
//                .tabItem {
//                    Label("Home", systemImage: "house")
//                }
//            StatsView(accessorySessionManager: accessorySessionManager)
//                .tabItem {
//                    Label("Stats", systemImage: "chart.xyaxis.line")
//                }
//        }
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Paired, \(isConnected ? "connected" : "not connected")")
                Button {
                    isConnected = accessorySessionManager.peripheralConnected
                } label: {
                    Text("Refresh whether connected")
                }
                
                List {
                    Button {
                        accessorySessionManager.connect()
                    } label: {
                        Text("Connect")
                    }
                    
                    LabeledContent {
                        Text(accessorySessionManager.pitch?.formatted() ?? "nil")
                    } label: {
                        Text("Pitch")
                    }
                    LabeledContent {
                        Text(accessorySessionManager.roll?.formatted() ?? "nil")
                    } label: {
                        Text("Roll")
                    }
                    LabeledContent {
                        Text(accessorySessionManager.yaw?.formatted() ?? "nil")
                    } label: {
                        Text("Yaw")
                    }
                    Label {
                        Text("Posture")
                    } icon: {
                        Circle()
                            .fill(accessorySessionManager.badPosture ?? false ? Color.red : Color.green)
                            .frame(width: 10, height: 10)
                    }
                    
                    Toggle("Haptics", isOn: $isHapticsOn)
                        .onChange(of: isHapticsOn) {
                            accessorySessionManager.setHaptics(hapticOn: isHapticsOn ? 1 : 0)
                        }
                    
                    NavigationLink {
                        StatsView(accessorySessionManager: accessorySessionManager)
                    } label: {
                        Text("Orientation flow")
                    }

                }.scrollDisabled(false)
                
                Spacer()
                Button {
                    accessorySessionManager.removeAccessory()
                    withAnimation {
                        accessoryPaired = false
                    }
                } label: {
                    Text("Reset app")
                }.buttonStyle(.bordered)
                .controlSize(.large)
            }.padding()
                .onAppear {
                    Task {
                        while !accessorySessionManager.peripheralConnected {
                            accessorySessionManager.connect()
                            try await Task.sleep(nanoseconds: 200000000)
                        }
                        
                        isConnected = accessorySessionManager.peripheralConnected
                    }
                }
        }
    }
}

#Preview {
    PairedView(accessorySessionManager: AccessorySessionManager())
}
