//
//  StatsView.swift
//  WristPlus
//
//  Created by Ishani Chowdhury on 7/22/24.
//

import SwiftUI
import Charts

let x = 6;

struct StatsView: View {
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
                             .padding(.leading, 300.0)
                             .padding(.top, 50)
                            // .colorInvert()
                     }

                 }).padding(.bottom, 760)
            }
            
            VStack{ // header
                HStack{
                    Text("Wrist Angle")
                        .font(.title)
                        .foregroundColor(Color("LightOr"))
                        Spacer()
                  /*  LogoImage()
                        .frame(width: 10, height: 10) */ //FIGURE OUT
                }
            } .padding(.bottom, 560)
                .padding(.leading, 30)
                .padding(.trailing, 30)
            
            VStack{ // chart
                HStack{
                    ChartContent()
                }
                .padding(.bottom, 200)
            }
            
            VStack{ // text describing fitness-y rings
                HStack{
                    Text("Typing Duration (Hours)")
                        .font(.title)
                        .foregroundColor(Color("LightOr"))
                        .padding(.leading,25)
                        
                }
            }.padding(.top, 200)
            .padding(.trailing, 80)
            
            VStack{ // hours typed (variables)
                HStack{ //FIGURE OUT VARIABLES
                    Text("6")
                        .font(.system(size: 70))
                  // let string = \(x)
                  // .foregroundColor(Color("LightOr"))
                    Spacer()
                    Text("0.5")
                        .font(.system(size: 70))
                    }
            }  .padding(.top, 370)
               .padding(.leading, 75)
               .padding(.trailing, 60)
       
            VStack{ //text under numbers
                ZStack{
                    HStack{
                        Text("Total time")
                                .font(.body)
                        Spacer()
                        Text("Average typing")
                            .font(.body)
                    }
                    HStack{
                        Text("typing")
                        .font(.body)
                        Spacer()
                        Text("block")
                            .padding(.leading,-65)
                        .font(.body)
                    } .padding(.top, 37)
                        .padding(.leading, 13)
                        .padding(.trailing,12)
                }
            } .padding(.top, 450)
              .padding(.leading, 60)
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
    StatsView()
}
