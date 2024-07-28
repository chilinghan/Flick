//
//  StatsView.swift
//  WristPlus
//
//  Created by Chiling Han on 7/26/24.
//

import Foundation
import SwiftUI

struct StatsView: View {
    @StateObject var accessorySessionManager: AccessorySessionManager

    var body: some View {
        
        ChartView(logs: $accessorySessionManager.logs)
            .padding()
    }
}
