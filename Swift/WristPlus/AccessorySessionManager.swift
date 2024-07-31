//
//  AccessoryConnection.swift
//  Chiling Han
//

import Foundation
import AccessorySetupKit
import CoreBluetooth
import SwiftUI

@Observable
class AccessorySessionManager: NSObject {
    var logs: [PitchLog] = []

    var accesoryModel: AccessoryModel?
    var rawYaw: String? = nil
    var rawRoll: String? = nil
    var rawPitch: String? = nil
    var rawBadPosture: String? = nil
    var rawTyping: String? = nil

    var peripheralConnected = false
    var pickerDismissed = true

    private var currentAccessory: ASAccessory?
    private var session = ASAccessorySession()
    private var manager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var yawCharacteristic: CBCharacteristic?
    private var rollCharacteristic: CBCharacteristic?
    private var pitchCharacteristic: CBCharacteristic?
    private var postureCharacteristic: CBCharacteristic?
    private var hapticCharacteristic: CBCharacteristic?
    private var typingCharacteristic: CBCharacteristic?

    private static let yawCharacteristicUUID = "E848839A-6DB5-4AA8-918A-5D0F2A131E0D"
    private static let rollCharacteristicUUID = "BEB5483E-36E1-4688-B7F5-EA07361B26A8"
    private static let pitchCharacteristicUUID = "066A8CE3-6217-4D38-AB95-E2C7EB872C4E"
    private static let postureCharacteristicUUID = "1BfCE46F-D96B-40F9-8EEB-B64F861AAD89"
    private static let hapticCharacteristicUUID = "AB3F4426-FFF9-42F9-9207-928245A924A5"
    private static let typingCharacteristicUUID = "46EA3751-2006-4F14-A09A-161DACE1AC5D"
    
    private static let wristPlus: ASPickerDisplayItem = {
        let descriptor = ASDiscoveryDescriptor()
        descriptor.bluetoothServiceUUID = AccessoryModel.wristPlus.serviceUUID

        return ASPickerDisplayItem(
            name: AccessoryModel.wristPlus.displayName,
            productImage: AccessoryModel.wristPlus.accessoryImage,
            descriptor: descriptor
        )
    }()

    override init() {
        super.init()
        self.session.activate(on: DispatchQueue.main, eventHandler: handleSessionEvent(event:))
    }

    // MARK: - AccessorySessionManager actions

    func setHaptics(hapticOn: UInt8) {
        let haptics = Data([hapticOn])

        peripheral?.writeValue(haptics, for: hapticCharacteristic!, type: .withResponse)
    }
    
    func setTyping(typingMode: UInt8) {
        let typing = Data([typingMode])
        peripheral?.writeValue(typing, for: typingCharacteristic!, type: .withResponse)
    }
    
    func getSecPosture() -> Double {
        var total = 0.0
        for pitchLog in logs {
            if !pitchLog.badPosture {
                total += 0.1 // 100ms
            }
        }
        return total
    }
    
    
    func presentPicker() {
        session.showPicker(for: [Self.wristPlus]) { error in
            if let error {
                print("Failed to show picker due to: \(error.localizedDescription)")
            }
        }
    }


    func removeAccessory() {
        guard let currentAccessory else { return }

        if peripheralConnected {
            disconnect()
        }

        session.removeAccessory(currentAccessory) { _ in
            self.accesoryModel = nil
            self.currentAccessory = nil
            self.manager = nil
        }
    }

    func connect() {
        guard
            let manager, manager.state == .poweredOn,
            let peripheral
        else {
            return
        }
        manager.connect(peripheral)
    }

    func disconnect() {
        guard let peripheral, let manager else { return }
        manager.cancelPeripheralConnection(peripheral)
    }

    // MARK: - ASAccessorySession functions

    private func saveAccessory(accessory: ASAccessory) {
        UserDefaults.standard.set(true, forKey: "accessoryPaired")
        
        currentAccessory = accessory

        if manager == nil {
            manager = CBCentralManager(delegate: self, queue: nil)
        }
        
        if accessory.displayName == AccessoryModel.wristPlus.displayName {
            accesoryModel = .wristPlus
        }
    }

    private func handleSessionEvent(event: ASAccessoryEvent) {
        switch event.eventType {
        case .accessoryAdded, .accessoryChanged:
            guard let accessory = event.accessory else { return }
            saveAccessory(accessory: accessory)
        case .activated:
            guard let accessory = session.accessories.first else { return }
            saveAccessory(accessory: accessory)
        case .accessoryRemoved:
            self.accesoryModel = nil
            self.currentAccessory = nil
            self.manager = nil
        case .pickerDidPresent:
            pickerDismissed = false
        case .pickerDidDismiss:
            pickerDismissed = true
        default:
            print("Received event type \(event.eventType)")
        }
    }
    
    
    var yaw: Measurement<UnitAngle>? {
        let string = rawYaw
        
        guard string != nil, let string = string else {
            return nil
        }
        
        if var number = Int(string, radix: 16) {
            if number > 180 {
                number -= 360
            }
            return Measurement(value: Double(number), unit: .degrees)
        } else {
            return nil
        }
    }

    var roll: Measurement<UnitAngle>? {
        let string = rawRoll

        guard string != nil, let string = string else {
            return nil
        }
        
        if var number = Int(string, radix: 16) {
            if number > 180 {
                number -= 360
            }
            return Measurement(value: Double(number), unit: .degrees)
        } else {
            return nil
        }
    }
    
    var pitch: Measurement<UnitAngle>? {
        let string = rawPitch
        
        guard string != nil, let string = string else {
            return nil
        }
        
        if var number = Int(string, radix: 16) {
            if number > 180 {
                number -= 360
            }
            return Measurement(value: Double(number), unit: .degrees)
        } else {
            return nil
        }
    }

    
    var badPosture: Bool? {
        let string = rawBadPosture
        
        guard string != nil, let string = string else {
            return nil
        }
        
        if let number = Int(string, radix: 16) {
            return number != 0
        } else {
            return nil
        }
    }
    
    var typing: Bool? {
        let string = rawTyping
        
        guard string != nil, let string = string else {
            return nil
        }
        
        if let number = Int(string, radix: 16) {
            return number != 0
        } else {
            return nil
        }
    }

}

// MARK: - CBCentralManagerDelegate

extension AccessorySessionManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central manager state: \(central.state)")
        switch central.state {
        case .poweredOn:
            if let peripheralUUID = currentAccessory?.bluetoothIdentifier {
                peripheral = central.retrievePeripherals(withIdentifiers: [peripheralUUID]).first
                peripheral?.delegate = self
                print(peripheralUUID)
            }
        default:
            peripheral = nil
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral)")
        guard let accesoryModel else { return }
        peripheral.delegate = self
        peripheral.discoverServices([accesoryModel.serviceUUID])

        peripheralConnected = true
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("Disconnected from peripheral: \(peripheral)")
        peripheralConnected = false
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        print("Failed to connect to peripheral: \(peripheral), error: \(error.debugDescription)")
    }
}

// MARK: - CBPeripheralDelegate

extension AccessorySessionManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard
            error == nil,
            let services = peripheral.services
        else {
            return
        }

        for service in services {
            peripheral.discoverCharacteristics([CBUUID(string: Self.yawCharacteristicUUID),
                                                CBUUID(string: Self.rollCharacteristicUUID),
                                                CBUUID(string: Self.pitchCharacteristicUUID),
                                                CBUUID(string: Self.postureCharacteristicUUID),
                                                CBUUID(string: Self.hapticCharacteristicUUID),
                                                CBUUID(string: Self.typingCharacteristicUUID)], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard
            error == nil,
            let characteristics = service.characteristics
        else {
            return
        }

        for characteristic in characteristics {
            if characteristic.uuid == CBUUID(string: Self.yawCharacteristicUUID) {
                yawCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
            if characteristic.uuid == CBUUID(string: Self.rollCharacteristicUUID) {
                rollCharacteristic = characteristic
                 peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
            if characteristic.uuid == CBUUID(string: Self.pitchCharacteristicUUID) {
                pitchCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
            if characteristic.uuid == CBUUID(string: Self.postureCharacteristicUUID) {
                postureCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
            if characteristic.uuid == CBUUID(string: Self.hapticCharacteristicUUID) {
                hapticCharacteristic = characteristic
                 peripheral.setNotifyValue(true, for: characteristic)
            }
            if characteristic.uuid == CBUUID(string: Self.typingCharacteristicUUID) {
                typingCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
        }
    }
    

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?){
        if characteristic.uuid == CBUUID(string: Self.yawCharacteristicUUID) {
            guard
                error == nil,
                let data = characteristic.value
            else {
                print("Error not able to read yaw")
                return
            }
            
            var rawMeasurements = data.map { String(format: "%02x", $0) }.joined()
            rawMeasurements = String(rawMeasurements.suffix(2)) + String(rawMeasurements.prefix(2))
            print("New yaw received: \(rawMeasurements)")

            DispatchQueue.main.async {
                withAnimation {
                    self.rawYaw = rawMeasurements
                }
            }
        }
        else if characteristic.uuid == CBUUID(string: Self.rollCharacteristicUUID) {
            guard
                error == nil,
                let data = characteristic.value
            else {
                print("Error not able to read roll")
                return
            }
            var rawMeasurements = data.map { String(format: "%02x", $0) }.joined()
//            var x = ((rawMeasurements & 0x00FF) << 8) | ((rawMeasurements & 0xFF00) >> 8);
            rawMeasurements = String(rawMeasurements.suffix(2)) + String(rawMeasurements.prefix(2))
            print("New roll received: \(rawMeasurements)")

            DispatchQueue.main.async {
                withAnimation {
                    self.rawRoll = rawMeasurements
                }
            }

        }
        else if characteristic.uuid == CBUUID(string: Self.pitchCharacteristicUUID) {
            guard
                error == nil,
                let data = characteristic.value
            else {
                print("Error not able to read pitch")
                return
            }
            var rawMeasurements = data.map { String(format: "%02x", $0) }.joined()
            rawMeasurements = String(rawMeasurements.suffix(2)) + String(rawMeasurements.prefix(2))
            print("New pitch received: \(rawMeasurements)")

            DispatchQueue.main.async {
                withAnimation {
                    self.rawPitch = rawMeasurements
                    if let p = self.pitch?.value {
                        if self.typing ?? true {
                            self.logs.append(PitchLog(date: Date.now, angle: p, badPosture: self.badPosture ?? false))
                        }
                    }
                }
            }
        }
        else if characteristic.uuid == CBUUID(string: Self.postureCharacteristicUUID) {
            guard
                error == nil,
                let data = characteristic.value
            else {
                print("Error not able to read bad posture")
                return
            }
            let rawMeasurements = String(data.map { String(format: "%02x", $0) }.joined())
            print("Bad posture: \(rawMeasurements)")

            DispatchQueue.main.async {
                withAnimation {
                    self.rawBadPosture = rawMeasurements
                }
            }
        }
        else if characteristic.uuid == CBUUID(string: Self.typingCharacteristicUUID) {
            guard
                error == nil,
                let data = characteristic.value
            else {
                print("Error not able to read typing")
                return
            }
            let rawMeasurements = String(data.map { String(format: "%02x", $0) }.joined())
            print("Typing: \(rawMeasurements)")

            DispatchQueue.main.async {
                withAnimation {
                    self.rawTyping = rawMeasurements
                }
            }
        }

    }
}
