//
//  DetectType4BTagWithAFICommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class DetectType4BTagWithAFICommand: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.type4
    
    @objc public let commandCode: UInt8 = Type4CommandCode.detectType4BTagWithAFI.rawValue
    
    @objc public private(set) var timeout: UInt8 = 0x00
    
    // Application Family Identifier (detects all tags when set to 0x00)
    @objc public private(set) var afi: UInt8 = 0x00
    
    @objc public var payload: [UInt8] {
        get {
            return [timeout] + [afi]
        }
    }
    
    @objc public init(timeout: UInt8, afi: UInt8) {
        super.init()
        
        self.timeout = timeout
        self.afi = afi
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 2 else {
            throw TCMPParsingError.payloadTooShort
        }
        timeout = payload[0]
        afi = payload[1]
    }
    
}
