//
//  SettingsView.swift
//  WristPlus
//
//  Created by Ishani Chowdhury on 7/29/24.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    let accessorySessionManager: AccessorySessionManager
    
    @State var isHapticsOn = true
    @State var isTypingOn = true
    
    var body: some View {
        ScrollView{
            VStack{
                VStack{ //sliders
                    Text("Device Options")
                        .padding(.top, 15)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.trailing, 120)
                        .padding(.top, 30)
                        .bold()
                    
                    VStack{ //physical switches
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 350, height: 47)
                                .foregroundColor(Color("BoxCol"))
                            Toggle("Haptics", isOn: $isHapticsOn)
                                .toggleStyle(SwitchToggleStyle(tint: Color("LightBl")))
                                .padding(.trailing, 40)
                                .font(.title2)
                                .foregroundColor(Color("LightBl"))
                                .padding(.leading, 40)
                                .onChange(of: isHapticsOn) {
                                    accessorySessionManager.setHaptics(hapticOn: isHapticsOn ? 1 : 0)
                                }
                        }
                    }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 350, height: 47)
                            .foregroundColor(Color("BoxCol"))
                        Toggle("Typing Mode", isOn: $isTypingOn)
                            .toggleStyle(SwitchToggleStyle(tint: Color("LightBl")))
                            .padding(.trailing, 40)
                            .font(.title2)
                            .foregroundColor(Color("LightBl"))
                            .padding(.leading, 40)
                            .onChange(of: isTypingOn) {
                                accessorySessionManager.setTyping(typingMode: isTypingOn ? 1 : 0)
                            }
                    }
                }; Spacer()
                VStack{ //sliders
                    Text("Device Information")
                        .padding(.top, 15)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.trailing, 80)
                        .bold()
                    
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 350, height: 47)
                            .foregroundColor(Color("BoxCol"))
                        Text("Device Battery")
                            .font(.title2)
                            .foregroundColor(Color("LightBl"))
                            .padding(.trailing, 180)
                        Image(systemName: "battery.50")
                            .font(.title2)
                            .foregroundColor(Color("LightBl"))
                            .padding(.leading, 40)
                        
                    }
                }; Spacer()
                VStack{ //sliders
                    Text("Bluetooth")
                        .padding(.top, 15)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.trailing, 200)
                        .bold()
                    
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 350, height: 47)
                            .foregroundColor(Color("BoxCol"))
                        Button {
                            accessorySessionManager.removeAccessory()
                            withAnimation {
                                accessorySessionManager.accessoryPaired = false
                            }
                        } label: {
                            Text("Re-Pair")
                                .font(.title2)
                                .foregroundColor(Color("LightBl"))
                                .padding(.trailing, 230)
                        }
                    } .padding(.bottom,7)
                }; Spacer()
                    VStack{ //goal
                        Text("Goal")
                            .padding(.top, 15)
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.trailing, 270)
                            .bold()
                    
                        ZStack{ //goal slider
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 350, height: 47)
                                .foregroundColor(Color("BoxCol"))
                            SliderView(accessorySessionManager: accessorySessionManager)
                                //.padding(.top,25)
                        }
                        
                    }; Spacer()
                }
            }
        }
    }
//}

/*#Preview {
    SettingsView(accessorySessionManager: AccessorySessionManager)
}*/

