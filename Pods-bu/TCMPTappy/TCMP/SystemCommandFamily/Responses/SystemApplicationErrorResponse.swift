//
//  SystemApplicationErrorResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-12.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

@objc public class SystemApplicationErrorResponse: NSObject, TCMPMessage, TCMPApplicationErrorMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.system
    
    @objc public private(set) var commandCode: UInt8 = SystemResponseCode.error.rawValue
    
    @objc public var payload: [UInt8] {
        get {
            return [appErrorCode, internalErrorCode, readerStatusCode] + errorDescription.utf8
        }
    }
    
    @objc public private(set) var appErrorCode: UInt8 = 0x00
    @objc public private(set) var internalErrorCode: UInt8 = 0x00
    @objc public private(set) var readerStatusCode: UInt8 = 0x00
    @objc public private(set) var errorDescription: String = ""
    
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 4 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        appErrorCode = payload[0]
        internalErrorCode = payload[1]
        readerStatusCode = payload[2]
        let errorDescriptionBytes = Data(payload[3...])
        errorDescription = String(data: errorDescriptionBytes, encoding: .utf8)!
    }
    
}
