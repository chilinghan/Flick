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
        
    var body: some View {
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
                    LabeledContent {
                        Text(accessorySessionManager.badPosture ?? false ? "Yes" : "No")
                    } label: {
                        Text("Bad posture")
                    }
                    
//                    LabeledContent {
//                        Text(accessorySessionManager.orientation?.name.capitalized ?? "nil")
//                    } label: {
//                        Text("Orientation")
//                    }
                    
//                    Toggle("Pump", isOn: $isRelayOn)
//                        .onChange(of: isRelayOn) {
//                            accessorySessionManager.setRelayState(isOn: isRelayOn)
//                        }
//                    
//                    NavigationLink {
//                        HomeView()
//                    } label: {
//                        Text("Orientation flow")
//                    }
                }.scrollDisabled(true)
                
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
