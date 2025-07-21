//
//  StatsView.swift
//  WristPlus
//
//  Created by Chiling Han on 7/26/24.
//

import Foundation
import SwiftUI

struct StatsView: View {

    @State var accessorySessionManager: AccessorySessionManager

    
    var body: some View {
        ScrollView{
            VStack{
                VStack{ //top
                    Text("My Angle")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.trailing, 180)
                        .padding(.top, 30)
                        .bold()

                }
                
                VStack{ //chart
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 350, height: 480)
                            .foregroundColor(Color("BoxCol"))
                        // bad
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 350, height: 400)
                            .foregroundColor(.red)
                            .opacity(0.2)
                        
                        // good
                        
                       RoundedRectangle(cornerRadius: 10)
                            .frame(width: 350, height: 160)
                            .foregroundColor(.green)
                            .opacity(0.2)
                        VStack{ // chart
                            HStack{
                                ChartView(logs: $accessorySessionManager.logs)
                                    .frame(width: 325, height: 455)
                                    .chartYScale(domain: -70...70)
                            }
                        }
                    }
                }
                
                VStack{ //time (out of goal)
                    Text("Total Time")
                        .padding(.top, 15)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.trailing, 200)
                        .bold()

                }
                
                VStack{ //time
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 350, height: 47)
                            .foregroundColor(Color("BoxCol"))
                        HStack{
                            Text(String(format: "%.2f", accessorySessionManager.getTotalSec()/3600))
                             Text("hours spent typing")
                         }
                      //  Text("\(accessorySessionManager.getTotalSec()/3600) hours spent typing")
                            .font(.title2)
                            .foregroundColor(Color("LightBl"))
                    }
                }
            }
        }
    }
}
/*#Preview {
    StatsView()
}*/

//String(format: "%.1f",


//
//  StatsView.swift
//  WristPlus
//
//  Created by Chiling Han on 7/26/24.
//

/*import Foundation
import SwiftUI

struct StatsView: View {
    @State var accessorySessionManager: AccessorySessionManager

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
                        ChartView(logs: $accessorySessionManager.logs)
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
}*/
