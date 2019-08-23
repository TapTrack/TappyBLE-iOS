//
//  TransceiveAPDUCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class TransceiveAPDUCommand: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.type4
    
    @objc public let commandCode: UInt8 = Type4CommandCode.transceiveAPDU.rawValue
    
    @objc public private(set) var apdu: [UInt8] = []
    
    @objc public var payload: [UInt8] {
        get {
            return apdu
        }
    }
    
    @objc public init(apdu: [UInt8]) {
        super.init()
        
        self.apdu = apdu
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 1 else {
            throw TCMPParsingError.payloadTooShort
        }
        apdu = payload
    }
    
}
