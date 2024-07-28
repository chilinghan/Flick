//
//  File.swift
//  WristPlus
//
//  Created by Chiling Han on 7/26/24.
//

import Foundation
import SwiftUI
import Charts

struct ChartView: View {
    @Binding var logs: [PitchLog]

    var body: some View {
        Chart(logs) { log in
            AreaMark(
                x: .value("Date", log.date),
                y: .value("Angle", log.angle)
            )
        }
    }
}
