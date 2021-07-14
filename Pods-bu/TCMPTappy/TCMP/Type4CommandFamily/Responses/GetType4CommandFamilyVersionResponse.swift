//
//  GetType4CommandFamilyVersionResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class GetType4CommandFamilyVersionResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.type4
    
    @objc public let commandCode: UInt8 = Type4ResponseCode.pollingErrorDetected.rawValue
    
    @objc public private(set) var majorVersion: UInt8 = 0x00

    @objc public private(set) var minorVersion: UInt8 = 0x00
    
    @objc public var payload: [UInt8] {
        get {
            return [majorVersion] + [minorVersion]
        }
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 2 else {
            throw TCMPParsingError.payloadTooShort
        }
        majorVersion = payload[0]
        minorVersion = payload[1]
    }
    
}
