//
//  DetectType4ATagCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class DetectType4ATagCommand: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.type4
    
    @objc public let commandCode: UInt8 = Type4CommandCode.detectType4ATag.rawValue

    @objc public private(set) var timeout: UInt8 = 0x00
    
    @objc public var payload: [UInt8] {
        get {
            return [timeout]
        }
    }
    
    @objc public init(timeout: UInt8) {
        super.init()
        
        self.timeout = timeout
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 1 else {
            throw TCMPParsingError.payloadTooShort
        }
        timeout = payload[0]
    }
    
}
