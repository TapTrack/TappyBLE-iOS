//
//  AutoPollingCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-08.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class AutoPollingCommand: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.basicNFC
    
    @objc public let commandCode: UInt8 = BasicNFCCommandCode.startAutoPolling.rawValue
    
    @objc public private(set) var scanMode: AutoPollingScanMode = AutoPollingScanMode.detectType2
    
    // Heartbeat has the format of the ping response.
    @objc public private(set) var heartbeatPeriod: UInt8 = 0x00
    
    // Any value other than 0x00 disables the buzzer on tag entry/exit.
    @objc public private(set) var suppressBuzzer: UInt8 = 0x00
    
    @objc public var payload: [UInt8] {
        get {
            return [scanMode.rawValue] + [heartbeatPeriod] + [suppressBuzzer]
        }
    }
    
    @objc public init(scanMode: AutoPollingScanMode, heartbeatPeriod: UInt8, suppressBuzzer: Bool) {
        super.init()
        
        self.scanMode = scanMode
        self.heartbeatPeriod = heartbeatPeriod
        self.suppressBuzzer = suppressBuzzer ? 0x01 : 0x00
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 3 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        // unwrap
        let scanMode = AutoPollingScanMode(rawValue: payload[0])
        if let scanMode = scanMode {
            self.scanMode = scanMode
        } else {
            throw TCMPParsingError.invalidAutoPollScanMode
        }
        heartbeatPeriod = payload[1]
        suppressBuzzer = payload[2]
    }
    
}
