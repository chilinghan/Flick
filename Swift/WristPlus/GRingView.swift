//
//  GRingView.swift
//  ActivityRings
//
//  Created by Chiling Han on 7/22/24.
//

import SwiftUI

struct GRingView: View {
    @State private var progress: CGFloat = 0.75
    @State private var image: String = "healthy"
    @State private var color: Color = Color("LightOr")

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
                .frame(width: 138, height: 138)
              //  .padding(10)
                .overlay {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: progress)
                  
                }
            
           /* Text("\(Int(progress * 100))%")
                .font(.title)
                .foregroundColor(color) */
        }
       /* .onTapGesture {
            withAnimation {
                if image == "unhealthy" {
                    image = "healthy"
                    color = Color("LightOr")
                    progress = 0.5 // some data
                }
                else {
                    image = "unhealthy"
                    color = .blue
                    progress = 0.2 // some data
                }
            }
        } */
    }
}

#Preview {
    GRingView()
}
