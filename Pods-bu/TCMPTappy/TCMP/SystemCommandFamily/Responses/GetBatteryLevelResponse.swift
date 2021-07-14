//
//  GetBatteryLevelResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-07.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class GetBatteryLevelResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.system
    
    @objc public let commandCode: UInt8 = SystemResponseCode.getBatteryLevel.rawValue
    
    private var _batteryLevel: UInt8 = 0x00
    @objc public var batteryLevel: Int {
        get {
            return Int(_batteryLevel)
        }
    }
    
    @objc public var payload: [UInt8] {
        get {
            return [_batteryLevel]
        }
    }
    
    
    @objc public init (payload: [UInt8]) throws {
        super.init();
        try parsePayload(payload: payload)
    }
    
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 1 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        _batteryLevel = payload[0]
    }
    
}
