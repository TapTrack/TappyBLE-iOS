//
//  EmulateURIRecordCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class EmulateURIRecordCommand: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.basicNFC
    
    @objc public let commandCode: UInt8 = BasicNFCCommandCode.emulateURIRecord.rawValue
    
    @objc public private(set) var timeout: UInt8 = 0x00
    @objc public private(set) var maxScans: UInt8 = 0x00
    @objc public private(set) var uriPrefixCode: UInt8 = 0x00 // prefix protocol
    @objc public private(set) var uri: [UInt8] = []
    
    @objc public var uriString: String {
        get {
            let uriPrefix = getUriProtocolFromCode(uriPrefixCode)
            let uriStr = String(bytes: uri, encoding: .utf8)
            return (uriStr != nil) ? (uriPrefix + uriStr!) : uriPrefix
        }
    }
    
    @objc public var payload: [UInt8] {
        get {
            return [timeout] + [maxScans] + [uriPrefixCode] + uri
        }
    }
    
    @objc public init(timeout: UInt8, maxScans: UInt8, uriPrefixCode: UInt8, uri: [UInt8]) {
        super.init()
        
        self.timeout = timeout
        self.maxScans = maxScans
        self.uriPrefixCode = uriPrefixCode
        self.uri = uri
    }
    
    @objc public convenience init(timeout: UInt8, maxScans: UInt8, uriPrefixCode: UInt8, uriStringNoPrefix: String) {
        self.init(timeout: timeout, maxScans: maxScans, uriPrefixCode: uriPrefixCode,
                  uri: Array(uriStringNoPrefix.utf8))
    }
    
    
    @objc public init(timeout: UInt8, maxScans: UInt8, uriStringWithPrefix: String) {
        super.init()
        
        self.timeout = timeout
        self.maxScans = maxScans
        
        let uriPrefix: (code: UInt8, length: Int) = getProtocolCodeFromUri(uriStringWithPrefix)
        self.uriPrefixCode = uriPrefix.code
        
        let index = uriStringWithPrefix.index(uriStringWithPrefix.startIndex, offsetBy: uriPrefix.length)
        let uriStringNoPrefix: String = String(uriStringWithPrefix[index...])
        self.uri = Array(uriStringNoPrefix.utf8)
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 3 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        timeout = payload[0]
        maxScans = payload[1]
        uriPrefixCode = payload[2]
        if payload.count > 3 {
            uri = Array(payload[3...])
        }
    }
    
}
