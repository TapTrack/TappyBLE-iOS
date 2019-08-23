//
//  ReadNdefWithPasswordCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-14.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class ReadNdefWithPasswordCommand: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.ntag21x
    
    @objc public let commandCode: UInt8 = Ntag21xCommandCode.readNdefFromPasswordProtectedTag.rawValue
    
    @objc public private(set) var timeout: UInt8 = 0x00
    
    @objc public private(set) var password: [UInt8] = []
    
    @objc private var passwordString: String {
        get {
            let _passwordString = String(bytes: password, encoding: .utf8)
            return (_passwordString != nil) ? _passwordString! : ""
        }
    }
    
    @objc private var passwordLength: [UInt8] {
        get {
            let lengthUInt16: UInt16 = UInt16(password.count)
            return [UInt8(lengthUInt16 >> 8), UInt8(lengthUInt16 & 0xFF)]
        }
    }
    
    @objc public var payload: [UInt8] {
        get {
            return [timeout] + passwordLength + password
        }
    }
    
    @objc public init?(timeout: UInt8, password: [UInt8]) {
        super.init()
        
        guard password.count <= UInt16.max else {
            NSLog("Password too long.")
            return nil
        }
        
        self.timeout = timeout
        self.password = password
    }
    
    @objc public init?(timeout: UInt8, passwordString: String) {
        super.init()
        
        guard password.count <= UInt16.max else {
            NSLog("Password too long.")
            return nil
        }
        
        self.timeout = timeout
        self.password = Array(passwordString.utf8)
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count > 3 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        timeout = payload[0]
        // skip two password length bytes
        password = Array(payload[3...])
    }
}
