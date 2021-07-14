//
//  Ntag21xReadSuccessResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-19.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class Ntag21xReadSuccessResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.ntag21x
    
    @objc public let commandCode: UInt8 = Ntag21xResponseCode.readSuccess.rawValue
    
    @objc public private(set) var tagType: UInt8 = 0x00
    
    @objc public private(set) var uid: [UInt8] = []
    
    @objc private var uidLength: UInt8 {
        get {
            return UInt8(uid.count)
        }
    }
    
    @objc public private(set) var ndefMessage: [UInt8] = []
    
    @objc public var payload: [UInt8] {
        get {
            return [tagType] + [uidLength] + uid + ndefMessage
        }
    }
        
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 3 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        self.tagType = payload[0]
        let uidLength: Int = Int(payload[1])
        
        guard (uidLength + 2) <= payload.count else {
            throw TCMPParsingError.payloadTooShort
        }
        self.uid = Array(payload[2..<(2 + uidLength)])
        
        if (2 + uidLength) < payload.count {
            self.ndefMessage = Array(payload[(2 + uidLength)...])
        }
    }
    
}
