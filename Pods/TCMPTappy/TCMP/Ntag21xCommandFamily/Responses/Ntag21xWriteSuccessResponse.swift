//
//  Ntag21xWriteSuccessResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-19.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class Ntag21xWriteSuccessResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.ntag21x
    
    @objc public let commandCode: UInt8 = Ntag21xResponseCode.commandFamilyVersion.rawValue
    
    @objc public private(set) var tagType: UInt8 = 0x00
    
    @objc public private(set) var uid: [UInt8] = []
    
    @objc public var payload: [UInt8] {
        get {
            return [tagType] + uid
        }
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 1 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        tagType = payload[0]
        uid = Array(payload[1...])
    }
    
}
