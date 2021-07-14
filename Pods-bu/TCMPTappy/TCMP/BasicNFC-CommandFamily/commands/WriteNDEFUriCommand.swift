//
//  WriteNDEFUriCommand.swift
//  TappyBLE
//
//  Created by Ga-Chun Lin on 2019-03-19.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

@objc public class WriteNDEFUriCommand : NSObject, TCMPMessage {
    
    @objc public let commandFamily : [UInt8] = CommandFamily.basicNFC
    
    @objc public let commandCode : UInt8 = BasicNFCCommandCode.writeURIRecord.rawValue
    
    @objc public var payload: [UInt8]{
        get {
            var lockFlagByte: UInt8
            if (lockFlag == LockingMode.LOCK_TAG) {
                lockFlagByte = 0x01
            } else {
                lockFlagByte = 0x00
            }
            
            return [timeout, lockFlagByte, uriPrefixCode] + uri
        }
    }
    
    @objc public private(set) var lockFlag : LockingMode = LockingMode.DONT_LOCK_TAG
    @objc public private(set) var timeout : UInt8 = 0
    @objc public private(set) var uriPrefixCode : UInt8 = 0x00
    @objc public private(set) var uri : [UInt8] = []
    
    @objc public var uriString: String {
        get {
            if uri.count == 0 {
                return ""
            }
            let uriPrefix: String = getUriProtocolFromCode(uri[0])
            let uriString = String(bytes: Array(uri[1...]), encoding: .utf8)
            return (uriString != nil) ? (uriPrefix + uriString!) : uriPrefix
        }
    }
    
    @objc public init(timeout: UInt8, lockTag: LockingMode, uriPrefixCode: UInt8, uri: [UInt8]){
        self.timeout = timeout
        self.lockFlag = lockTag
        self.uriPrefixCode = uriPrefixCode
        self.uri = uri
    }
    
    @objc public convenience init(timeout: UInt8, lockTag: LockingMode, uriPrefixCode: UInt8, uriStringNoPrefix: String) {
        self.init(timeout: timeout, lockTag: lockTag, uriPrefixCode: uriPrefixCode,
                  uri: Array(uriStringNoPrefix.utf8))
    }
    
    
    @objc public init(timeout: UInt8, lockTag: LockingMode, uriStringWithPrefix: String) {
        super.init()
        
        self.timeout = timeout
        self.lockFlag = lockTag
        
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
    
    @objc public func parsePayload(payload : [UInt8]) throws {
        if (payload.count > 2) {
            timeout = payload[0]
            
            if (payload[1] == 0x00) {
                lockFlag = LockingMode.DONT_LOCK_TAG
            } else {
                lockFlag = LockingMode.LOCK_TAG
            }
            
            uriPrefixCode = payload[2]
            
            if (payload.count > 3) {
                uri = Array(payload[3...payload.count-1])
            } else {
                uri = []
            }
        
        } else {
            throw TCMPParsingError.payloadTooShort
        }
    }
    
    // Deprecated after version 0.1.12. Left here for legacy reasons.
    @objc static func getCommandCode() -> UInt8{
        return 0x05
    }
    
}
