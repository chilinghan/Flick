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
    
    @State var isHapticsOn = false
    @State var isTypingOn = false
    
    var body: some View {
        ScrollView{
            VStack{
                
                VStack{ //sliders
                    Text("Device Options")
                        .padding(.top, 15)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.trailing, 120)
                    
                    
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
                            // .onChange(of: isHapticsOn) {
                            // accessorySessionManager.setHaptics(hapticOn: isHapticsOn ? 1 : 0)
                            // }
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
                    }
                }; Spacer()
                VStack{ //sliders
                    Text("Device Information")
                        .padding(.top, 15)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.trailing, 80)
                    
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 350, height: 47)
                            .foregroundColor(Color("BoxCol"))
                        Text("Device Battery")
                            .font(.title2)
                            .foregroundColor(Color("LightBl"))
                            .padding(.trailing, 180)
                        Image("battery.50")
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
                    
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 350, height: 47)
                            .foregroundColor(Color("BoxCol"))
                        Button {
                            accessorySessionManager.presentPicker()
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
                    
                        ZStack{ //goal slider
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 350, height: 47)
                                .foregroundColor(Color("BoxCol"))
                                .padding(.bottom,25)
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

