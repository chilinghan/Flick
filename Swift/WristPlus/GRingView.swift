//
//  GRingView.swift
//  ActivityRings
//
//  Created by Chiling Han on 7/22/24.
//

import SwiftUI

struct GRingView: View {
    @State var accessorySessionManager: AccessorySessionManager
    @State private var image: String = "healthy"
    @State private var color: Color = Color("LightBl")

    var body: some View {
        ZStack {
            Image("image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 210, height: 250)
            Image("GP")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.top,7)
                .padding(.trailing,9)
                .frame(width: 240, height: 240)
                .colorInvert()
            Circle()
                .trim(from: 0, to: (1))
                .stroke(color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .opacity(0.2)
                .frame(width: 250, height: 250)
              //  .padding(10)
                .overlay {
            if accessorySessionManager.progress == 0 {
                Circle()
                    .trim(from: 0, to: (1))
                    .stroke(color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .opacity(0.0)
                    .frame(width: 250, height: 250)
            } else {
                    Circle()
                        .trim(from: 0, to: ((accessorySessionManager.progress)/100)*2)
                        .stroke(color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: ((accessorySessionManager.progress)/100)*2)
                    }
                }
            
          /*  Text("\(Double(accessorySessionManager.progress/100)*2)%")
                .font(.title)
                .foregroundColor(color) */
        }
    }
}

/*#Preview {
    GRingView(progress: 5.0)
}*/
