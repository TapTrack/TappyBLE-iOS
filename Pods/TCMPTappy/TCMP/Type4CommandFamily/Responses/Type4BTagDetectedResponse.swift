//
//  Type4BTagDetectedResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class Type4BTagDetectedResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.type4
    
    @objc public let commandCode: UInt8 = Type4ResponseCode.type4BTagDetected.rawValue
    
    @objc public private(set) var atqb: [UInt8] = []
    
    @objc public private(set) var attrib: [UInt8] = []
    
    @objc public var payload: [UInt8] {
        get {
            return atqb + attrib
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
        let atqbLength: Int = Int(payload[0])
        let attribLength: Int = Int(payload[1])
        
        if atqbLength > 0 {
            atqb = Array(payload[2..<(2 + atqbLength)])
        }

        if attribLength > 0 {
            attrib = Array(payload[(2 + atqbLength)..<(2 + atqbLength + attribLength)])
        }
    }
    
}
