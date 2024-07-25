//
//  ContentView.swift
//  WristPlus
//
//  Created by Hunter T on 7/21/24.
//

import SwiftUI

struct ContentView: View {
    
    @State var accessorySessionManager = AccessorySessionManager()
    @AppStorage("accessoryPaired") private var accessoryPaired = false

    var body: some View {
        if accessoryPaired {
            PairedView(accessorySessionManager: accessorySessionManager)
        } else {
            VStack {
                VStack {
                    Text("WristPlus")
                        .font(.system(size: 50, weight: .bold))                    .fontWeight(.bold)
                        .padding(.top, 20)
                }
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                Spacer(minLength: 20)

                
                Button {
                    accessorySessionManager.presentPicker()
                } label: {
                    Text("Pair")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, 28)
                .padding(.top, 20) // Add top padding to create some space between the image and the button
                                
                Spacer()
            }
        }
    }
}


#Preview {
    ContentView()
}
