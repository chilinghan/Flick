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
    let circleSizeRange: ClosedRange<CGFloat> = 10...30
    let sliderRange: ClosedRange<Double> = 0.0...10.0
    
    var body: some View {
        StepwiseSlider(value: $sliderValue,
                           circleSizeRange: circleSizeRange,
                           sliderRange: sliderRange
                          )
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

