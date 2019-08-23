//
//  GetHardwareVersionResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-07.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class GetHardwareVersionResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.system
    
    @objc public let commandCode: UInt8 = SystemResponseCode.getHardwareVersion.rawValue
    
    @objc public var payload: [UInt8] {
        get {
            return [_majorVersion] + [_minorVersion]
        }
    }
    
    private var _majorVersion: UInt8 = 0x00
    @objc public var majorVersion: Int {
        get {
            return Int(_majorVersion)
        }
    }
    
    private var _minorVersion: UInt8 = 0x00
    @objc public var minorVersion: Int {
        get {
            return Int(_minorVersion)
        }
    }
    
    
    @objc public init (payload: [UInt8]) throws {
        super.init();
        try parsePayload(payload: payload)
    }
    
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 2 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        _majorVersion = payload[0]
        _minorVersion = payload[1]
    }
    
}
