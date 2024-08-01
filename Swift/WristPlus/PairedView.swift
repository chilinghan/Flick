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
    //let CustomSlider: CustomSlider
    
   /* var minValue: Double
    var maxValue: Double
    var step: Double */
    
    @State private var sliderValue: Double = .zero
    @State var isConnected = false
    @State var isHapticsOn = false
    @State var isTypingOn = false
    
    private let step: Double = 1.0
    private let minValue: Double = 0.0
    private let maxValue: Double = 5.0
    private let circleSize: CGFloat = 15.0
    
    var body: some View {
        TabView {
            HomeView(accessorySessionManager: accessorySessionManager)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            StatsView(accessorySessionManager: accessorySessionManager)
                .tabItem {
                    Label("Stats", systemImage: "chart.xyaxis.line")
                }
           // SettingsView()
            
        }
       NavigationStack {
            VStack {
                Spacer()
                
                Text("Paired, \(isConnected ? "connected" : "not connected")")
                Button {
                    isConnected = accessorySessionManager.peripheralConnected
                } label: {
                    Text("Refresh whether connected")
                }
                
                ZStack {
                    // Slider
                    CustomSlider(
                        value: $sliderValue,
                        minValue: minValue,
                        maxValue: maxValue,
                        step: step,
                        thumbColor: .accentColor, trackColor: .accentColor, // Customize thumb color here
                        trackBackgroundColor: .accentColor
                    )
                    
                    // Overlay circles for step values
                    GeometryReader { geometry in
                        ZStack {
                            ForEach(Array(stride(from: minValue, through: maxValue, by: step)), id: \.self) { value in
                                Circle()
                                    .frame(width: circleSize, height: circleSize)
                                    .foregroundColor(.accentColor)
                                    .position(
                                        x: CGFloat((value - minValue) / (maxValue - minValue)) * (geometry.size.width - circleSize) + (circleSize / 2),
                                        y: geometry.size.height / 2
                                    )
                            }
                        }
                    }
                    .allowsHitTesting(false) // Prevent circles from blocking slider interaction
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

                }.scrollDisabled(false)
                
                
                Spacer()
                
                Button {
                    accessorySessionManager.removeAccessory()
                    withAnimation {
                        accessorySessionManager.accessoryPaired = false
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

/*#Preview {
    PairedView(accessorySessionManager: AccessorySessionManager())
}
*/
