//
//  HomeView.swift
//  WristPlus
//
//  Created by Ishani Chowdhury on 7/22/24.
//

import SwiftUI

struct HomeView: View {
    @State var accessorySessionManager: AccessorySessionManager
    
    var body: some View {
       ScrollView{
            VStack{
                VStack{ //goal
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 350, height: 47)
                            .foregroundColor(Color("BoxCol"))
                            .padding(.top, 90)
                        let goalTime = accessorySessionManager.goalTime
                        let hourTitle = goalTime > 1 ? "Hours" : "Hour"
                        HStack{
                            Text("My Goal:")
                            Text(String(format: "%.2f", goalTime))
                             Text("\(hourTitle)")
                         }
                            .font(.title2)
                            .foregroundColor(Color("LightBl"))
                            .padding(.top, 90)
                        VStack{ //top
                            Text("Summary")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding(.trailing, 180)
                                .padding(.bottom, 50)
                                .padding(.top, 30)
                                .bold()

                        }
                    }
                } .padding(.bottom, 10)
         
               
                
                VStack{ //fitnessring
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 350, height: 340)
                            .foregroundColor(Color("BoxCol"))
                            .padding(.top, 50)
                        GRingView(accessorySessionManager: accessorySessionManager)
                            .padding(.top,40)

                        VStack{ //Activity
                            Text("Activity")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding(.trailing, 210)
                                .padding(.bottom,340)
                                .bold()

                        }
                    } .padding(.top, 20)
                }
            }
            
              VStack{ // x/60
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 350, height: 47)
                            .foregroundColor(Color("BoxCol"))
                        let goalTime = (accessorySessionManager.goalTime)
                        let hourTitle = goalTime > 1 ? "Hours" : "Hour"
                        let timeDone = (accessorySessionManager.getSecPosture()/3600)
                       HStack{
                            Text(String(format: "%.2f", timeDone))
                            Text("/")
                            Text(String(format: "%.2f", goalTime))
                            Text("\(hourTitle)")
                        }
                            .font(.title2)
                            .foregroundColor(Color("LightBl"))
                    }
                } .padding(.bottom,5)
                    
                   /* VStack{ //trends
                        Text("Trends")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.trailing, 200)
                    }
                    
                    VStack{ //trends box
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 350, height: 340)
                                .foregroundColor(Color("BoxCol"))
                            Text("trendssssss")
                                .font(.title)
                                .foregroundColor(Color("LightBl"))
                        }
                    } */
                }
            }
        }
  // }
//}
#Preview {
    HomeView(accessorySessionManager: AccessorySessionManager())
}
