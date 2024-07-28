//
//  PitchLog.swift
//  WristPlus
//
//  Created by Chiling Han on 7/26/24.
//

import Foundation
import SwiftData

@Model
final class PitchLog: Identifiable {
  @Attribute(.unique) var id = UUID()
  var date: Date
  var angle: Double
  // No relationship attribute needed

  init(date: Date, angle: Double) {
    self.date = date
    self.angle = angle
  }
}
