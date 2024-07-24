//
//  ContentView.swift
//  WristPlus
//
//  Created by Hunter T on 7/21/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var navigateToBluetoothView = false

    var body: some View {
        VStack {
            VStack {
                Text("WristPlus")
                    .font(.system(size: 50, weight: .bold))                    .fontWeight(.bold)
                    .padding(.top, 20)
            }
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fill)
            VStack {
                Button(action: {withAnimation {
                    navigateToBluetoothView = true
                }
                }) {
                    Text("Continue")
                        .padding()
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .padding(.bottom, 20)
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $navigateToBluetoothView) {
            DeviceView()
                .transition(.opacity)
        }
    }
}

#Preview {
    ContentView()
}
