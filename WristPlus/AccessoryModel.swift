//
//  AccessoryModel.swift
//  Flex
//

import Foundation
import CoreBluetooth
import UIKit

enum AccessoryModel {
    case wristPlus
    
    var accessoryName: String {
        switch self {
            case .wristPlus: "Mojave WristPlus"
        }
    }
    
    var displayName: String {
        switch self {
            case .wristPlus: "WristPlus"
        }
    }
    
    var serviceUUID: CBUUID {
        switch self {
            case .wristPlus: CBUUID(string: "4FAFC201-1FB5-459E-8FCC-C5C9C331914B")
        }
    }
    
    var accessoryImage: UIImage {
        switch self {
        case .wristPlus: .image
        }
    }
}
