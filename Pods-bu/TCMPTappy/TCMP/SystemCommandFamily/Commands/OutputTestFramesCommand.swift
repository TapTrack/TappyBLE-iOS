//
//  OutputTestFramesCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-09.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class OutputTestFramesCommand: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.system
    
    @objc public let commandCode: UInt8 = SystemCommandCode.outputTestFrames.rawValue
    
    @objc private var millisecondDelay: [UInt8] = []
    
    @objc public var payload: [UInt8] {
        get {
            return millisecondDelay
        }
    }
    
    @objc public init(delay: UInt16) {        
        // Split Int to two separate bytes
        self.millisecondDelay.append(UInt8((delay >> 8) & 0xFF))
        self.millisecondDelay.append(UInt8(delay & 0xFF))
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count == 2 else {
            throw TCMPParsingError.payloadTooShort
        }
        millisecondDelay = payload
    }
    
}
