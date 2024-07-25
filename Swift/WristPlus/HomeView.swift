//
//  HomeView.swift
//  WristPlus
//
//  Created by Ishani Chowdhury on 7/22/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack{
            VStack{ // top of page
                Button(action: {
                     
                 }, label: {
                     ZStack {
                         RoundedRectangle(cornerRadius: 10)
                             .frame(height: 120)
                             .foregroundColor(Color("LightOr"))
                             .border(.black, width: 1.5)
                         
                         Image(systemName: "gear")
                             .resizable()
                             .foregroundColor(Color.white)
                             .frame(width: 40, height: 40)
                             .padding(.leading, 305.0)
                             .padding(.top, 50)
                     }

                 }).padding(.bottom, 760)
            }
            
            VStack{ // header/battery
                HStack{
                    Text("60 minutes")
                        .font(.title)
                        .foregroundColor(Color("LightOr"))
                        Spacer()
                    Image(systemName: "line.3.horizontal") //ADD SLIDER WHEN CLICKED
                        .resizable()
                        .foregroundColor(Color("LightOr"))
                        .frame(width: 30, height: 18)
                  /*  LogoImage()
                        .frame(width: 10, height: 10) */ //FIGURE OUT
                }
            } .padding(.bottom, 560)
                .padding(.leading, 30)
                .padding(.trailing, 30)
            
            VStack{ // psuedo fitness-ring
               
                HStack{
                    
                    GRingView()
                }
                .padding(.bottom, 200)
                .padding()
            }
            
            VStack{ // text describing fitness-y rings
                Text("0 minutes") //ADD VARIABLES TO NUM AND MINS (to hours)
                    .font(.system(size:30))
                    .foregroundColor(.green)
                    .padding(.top,45)
                    .padding()
                Text("0 minutes")
                    .font(.system(size:30))
                    .foregroundColor(.red)
            }.padding(.top, 100)
            .padding(.trailing, 70)
            .padding(.leading, 70)
            
            VStack{ // keyboard and vibration
                HStack{ //FIGURE OUT HOW TO TOGGLE ON AND OFF)
                    Button(action: {
                        // ProfileView()
                    }, label: {
                        Image(systemName: "switch.2")
                            .resizable()
                            .frame(width: 40, height: 30)
                            .foregroundColor(Color("LightOr"))
                    })
                    Spacer()
                    Button(action: {
                         
                    }, label: {
                        Image(systemName: "keyboard")
                            .resizable()
                            .frame(width: 40, height: 30)
                            .foregroundColor(Color("LightOr"))
                    })
                    Spacer()
                    Button(action: {
                         
                    }, label: {
                        Image(systemName: "battery.50")
                            .resizable()
                            .frame(width: 40, height: 30)
                            .foregroundColor(Color("LightOr"))
                    })
                }
            } .padding(.top, 390)
               .padding(.leading, 67)
               .padding(.trailing, 56)
            
            VStack{ //text describing action icons
                HStack{
                        Text("Vibrate ON")
                            .font(.body)
                    Spacer()
                    Text("Typing ON")
                        .font(.body)
                    Spacer()
                    Text("Battery")
                        .font(.body)
                }
            }
              .padding(.top, 450)
              .padding(.leading, 40)
              .padding(.trailing, 50)
            
            VStack{ // home bar
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 120)
                        .foregroundColor(.white)
                        .opacity(0)
                        .border(.black, width: 1.5)
                }

                 }.padding(.top, 800)
            }
           
        }
    }

#Preview {
    HomeView()
}
