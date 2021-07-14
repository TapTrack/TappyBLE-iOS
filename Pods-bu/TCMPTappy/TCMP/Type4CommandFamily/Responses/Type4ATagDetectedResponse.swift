//
//  Type4ATagDetectedResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class Type4ATagDetectedResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.type4
    
    @objc public let commandCode: UInt8 = Type4ResponseCode.type4ATagDetected.rawValue
    
    @objc public private(set) var uid: [UInt8] = []
    
    @objc public private(set) var ats: [UInt8] = []
    
    @objc public var payload: [UInt8] {
        get {
            return [UInt8(uid.count)] + uid + ats
        }
    }
    
    @objc public required init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 2 else {
            throw TCMPParsingError.payloadTooShort
        }
        let uidLength = Int(payload[0])
        self.uid = Array(payload[1..<(1 + uidLength)])
        self.ats = Array(payload[(1 + uidLength)...])
    }
    
}
