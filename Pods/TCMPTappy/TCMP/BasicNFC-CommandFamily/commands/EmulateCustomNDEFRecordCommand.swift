//
//  EmulateCustomNDEFRecordCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class EmulateCustomNDEFRecordCommand: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.basicNFC
    
    @objc public let commandCode: UInt8 = BasicNFCCommandCode.emulateCustomNDEFRecord.rawValue
    
    @objc public private(set) var timeout: UInt8 = 0x00
    @objc public private(set) var maxScans: UInt8 = 0x00
    @objc public private(set) var content: [UInt8] = []
    
    @objc public var payload: [UInt8] {
        get {
            return [timeout] + [maxScans] + content
        }
    }
    
    @objc public init(timeout: UInt8, maxScans: UInt8, content: [UInt8]) {
        super.init()
        
        self.timeout = timeout
        self.maxScans = maxScans
        self.content = content
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
        maxScans = payload[1]
        if payload.count > 2 {
            content = Array(payload[2...])
        }
    }
    
}
