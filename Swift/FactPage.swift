//
//  FactPage.swift
//  WristPlus
//
//  Created by Ishani Chowdhury on 7/17/24.
//

import SwiftUI

struct FactPage: View {
    var body: some View {
        VStack {
            Text("Facts + Information")
                .padding(.leading, -60.0)
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                
            }, label: {
                RoundedRectangle(cornerRadius: 10)
                    //.frame(height: 90)
                    .foregroundColor(Color("LightPurple"))
                    //.border(.teal, width: 1.5)
            }).padding(.horizontal)
               // .padding(.vertical)
            
            
            HStack{
                Button(action: {
                    
                }, label: {
                    RoundedRectangle(cornerRadius: 10)
                        //.frame(height: 90)
                        .foregroundColor(Color("LightPurple"))
                        //.border(.teal, width: 1.5)
                })
                Button(action: {
                    
                }, label: {
                    RoundedRectangle(cornerRadius: 10)
                        //.frame(height: 90)
                        .foregroundColor(Color("LightPurple"))
                        //.border(.teal, width: 1.5)
                })
            }.padding(.horizontal)
              //  .padding(.vertical)
          
            
            HStack{
                Button(action: {
                    
                }, label: {
                    RoundedRectangle(cornerRadius: 10)
                        //.frame( height: 90)
                        .foregroundColor(Color("LightPurple"))
                        //.border(.teal, width: 1.5)
                })
                Button(action: {
                    
                }, label: {
                    RoundedRectangle(cornerRadius: 10)
                        //.frame( height: 90)
                        .foregroundColor(Color("LightPurple"))
                        //.border(.teal, width: 1.5)
                })
            }.padding(.horizontal)
                //.padding(.vertical)
            
            
            HStack{
                Button(action: {
                    
                }, label: {
                    RoundedRectangle(cornerRadius: 10)
                        //.frame(height: 90)
                        .foregroundColor(Color("LightPurple"))
                })
                Button(action: {
                    
                }, label: {
                    RoundedRectangle(cornerRadius: 10)
                        //.frame(height: 90)
                        .foregroundColor(Color("LightPurple"))
                })
                Button(action: {
                    
                }, label: {
                    RoundedRectangle(cornerRadius: 10)
                        //.frame(height: 90)
                        .foregroundColor(Color("LightPurple"))
                        //.border(.teal, width: 1.5)
                })
            } .padding(.horizontal)

            
           Button(action: {
                
            }, label: {
                RoundedRectangle(cornerRadius: 10)
                    //.frame(height: 90)
                    .foregroundColor(Color("LightPurple"))
                    //.border(.teal, width: 1.5)
            }).padding(.horizontal)
            
            
             Button(action: {
                 
             }, label: {
                 ZStack {
                     RoundedRectangle(cornerRadius: 10)
                         //.frame(height: 90)
                     .foregroundColor(Color("DarkPurple"))
                     
                     Text("Further Resources")
                         .font(.title)
                         .foregroundColor(Color.white)
                         .padding()
                 }
                     //.border(.teal, width: 1.5)
             })
                .padding(.horizontal)
                .padding(.bottom, 0.0)
                .frame(height: 60.0)
            
        }
    }
}

#Preview {
    FactPage()
}

