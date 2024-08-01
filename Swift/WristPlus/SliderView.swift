//
//  SliderView.swift
//  WristPlus
//
//  Created by Ishani Chowdhury on 7/29/24.
//

import Foundation
import SwiftUI
//import Combine


/*class SliderViewModel: ObservableObject {
    @Published var value: Double
}
*/

struct SliderView: View {
    let accessorySessionManager: AccessorySessionManager
    
    @State private var sliderValue: Double = .zero
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            Slider(
                value: $sliderValue,
                in: 0...10,
                step: 0.5,
                onEditingChanged: { editing in
                    isEditing = editing
                },
                minimumValueLabel: Text("0"),
                maximumValueLabel: Text("10"),
                label: {
                    Text("Values from 0 to 10")
                }
            )
            Text("\(sliderValue, specifier: "%.2f")")
                .foregroundColor(isEditing ? .white : Color("LightBl"))
        }
        .padding()
        .onChange(of: sliderValue) { _, newValue in
            accessorySessionManager.goalTime = Double(newValue)
           if accessorySessionManager.getGoalSec() == 0.0 {
                accessorySessionManager.progress = 0.0
            } else {
                accessorySessionManager.progress = accessorySessionManager.getSecPosture() / accessorySessionManager.getGoalSec()
            }
        }
    }
}

/*#Preview {
    SliderView(accessorySessionManager: accessorySessionManager)
}*/

