//
//  WriteCustomNdefWithPasswordBytesCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-16.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class WriteCustomNdefWithPasswordBytesCommand: NSObject, TCMPMessage, WriteNtag21xWithPasswordBytesCommand {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.ntag21x
    
    @objc public let commandCode: UInt8 = Ntag21xCommandCode.writeCustomNdefWithPasswordBytes.rawValue
    
    @objc public private(set) var timeout: UInt8 = 0x00
    
    @objc public private(set) var passwordProtection: Ntag21xProtectionMode = Ntag21xProtectionMode.writeProtection
    
    @objc public private(set) var password: [UInt8] = []
    
    @objc public private(set) var passwordAcknowledgement: [UInt8] = []
    
    @objc public private(set) var content: [UInt8] = []
    
    @objc private var contentLength: [UInt8] {
        get {
            let lengthUInt16: UInt16 = UInt16(content.count)
            return [UInt8(lengthUInt16 >> 8), UInt8(lengthUInt16 & 0xFF)]
        }
    }
    
    @objc public var payload: [UInt8] {
        get {
            var _payload: [UInt8] = []
            
            _payload.append(timeout)
            _payload.append(passwordProtection.rawValue)
            _payload += password + passwordAcknowledgement
            _payload += contentLength + content
            
            return _payload
        }
    }
    
    
    @objc required public init?(timeout: UInt8, readProtection: Bool, password: [UInt8],
                                passwordAcknowledgement: [UInt8], content: [UInt8]) {
        super.init()
        
        guard password.count == 4 else {
            NSLog("Password must be four bytes long.")
            return nil
        }
        guard passwordAcknowledgement.count == 2 else {
            NSLog("Password acknowledgement must be two bytes long.")
            return nil
        }
        guard content.count <= UInt16.max else {
            NSLog("Content too long.")
            return nil
        }
        
        self.passwordProtection = readProtection ?
            Ntag21xProtectionMode.readAndWriteProtection : Ntag21xProtectionMode.writeProtection
        self.password = password
        self.passwordAcknowledgement = passwordAcknowledgement
        self.content = content
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 10 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        timeout = payload[0]
        
        let protectionMode = Ntag21xProtectionMode(rawValue: payload[1])
        if let protectionModeUnwrapped = protectionMode {
            self.passwordProtection = protectionModeUnwrapped
        } else {
            throw TCMPParsingError.invalidPasswordProtectionMode
        }
        
        password = Array(payload[2...5])
        passwordAcknowledgement = Array(payload[6...7])
        
        // skip two content length bytes
        if 10 < payload.count {
            content = Array(payload[10...])
        }
    }
    
}
