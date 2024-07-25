//
//  LoginPage.swift
//  WristPlus
//
//  Created by Ishani Chowdhury on 7/23/24.
//

import SwiftUI

struct LoginPage: View {
    var body: some View {
        ZStack{
            VStack{
                //HAVE BOOLEAN SO CAN CLICK THROUGH BUT DOESNT DISPLAY MANY TIMES
                Text("WristPlus")
                    .font(.system(size: 50))
                    .foregroundColor(Color("LightOr"))
            } .padding(.bottom, 525)
            
            VStack{
                Image("WristPlusLogo")
                    .resizable()
                    .frame(width: 600, height: 600)
                    .padding(.bottom, 75)
            }
            
            
            Button(action: {
                
            }, label: {
                ZStack{
                    VStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 250, height: 70)
                            .foregroundColor(Color("LightOr"))
                            .padding()
                            .padding(.top, 400)
                    }
                    Text("Start tracking")
                        .foregroundColor(.white)
                        .font(.system(size: 25))
                        .padding(.top,400)
                    
                }
            })
        }
    }
}

#Preview {
    LoginPage()
}
