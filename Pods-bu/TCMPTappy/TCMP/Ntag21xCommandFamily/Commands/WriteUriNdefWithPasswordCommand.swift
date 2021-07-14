//
//  WriteUriNdefWithPasswordCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-14.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class WriteUriNdefWithPasswordCommand: NSObject, TCMPMessage, WriteNtag21xWithPasswordCommand {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.ntag21x
    
    @objc public let commandCode: UInt8 = Ntag21xCommandCode.writeUriNdefWithPassword.rawValue
    
    @objc public private(set) var timeout: UInt8 = 0x00
    
    @objc public private(set) var passwordProtection: Ntag21xProtectionMode = Ntag21xProtectionMode.writeProtection
    
    @objc public private(set) var password: [UInt8] = []
    
    @objc private var passwordLength: [UInt8] {
        get {
            let lengthUInt16: UInt16 = UInt16(password.count)
            return [UInt8(lengthUInt16 >> 8), UInt8(lengthUInt16 & 0xFF)]
        }
    }
    
    @objc public var passwordString: String {
        get {
            let _passwordString = String(bytes: password, encoding: .utf8)
            return (_passwordString != nil) ? _passwordString! : ""
        }
    }
    
    @objc public private(set) var content: [UInt8] = []
    
    @objc private var contentLength: [UInt8] {
        get {
            let lengthUInt16: UInt16 = UInt16(content.count)
            return [UInt8(lengthUInt16 >> 8), UInt8(lengthUInt16 & 0xFF)]
        }
    }
    
    @objc public var uri: String {
        get {
            if content.count == 0 {
                return ""
            }
            let uriPrefix: String = getUriProtocolFromCode(content[0])
            let uriString = String(bytes: Array(content[1...]), encoding: .utf8)
            return (uriString != nil) ? (uriPrefix + uriString!) : uriPrefix
        }
    }
    
    @objc public var payload: [UInt8] {
        get {
            var _payload: [UInt8] = []
            
            _payload.append(timeout)
            _payload.append(passwordProtection.rawValue)
            _payload += passwordLength + password
            _payload += contentLength + content
            
            return _payload
        }
    }
    
    
    @objc required public init?(timeout: UInt8, readProtection: Bool, password: [UInt8], content: [UInt8]) {
        super.init()
        
        guard password.count <= UInt16.max else {
            NSLog("Password too long.")
            return nil
        }
        guard content.count <= UInt16.max else {
            NSLog("URI too long.")
            return nil
        }
        
        self.passwordProtection = readProtection ?
            Ntag21xProtectionMode.readAndWriteProtection : Ntag21xProtectionMode.writeProtection
        self.password = password
        self.content = content
    }
    
    @objc public convenience init?(timeout: UInt8, readProtection: Bool, passwordString: String, uriString: String) {
        let uriPrefix: (code: UInt8, length: Int) = getProtocolCodeFromUri(uriString)
        var encodedUri = [uriPrefix.code]
        
        let index = uriString.index(uriString.startIndex, offsetBy: uriPrefix.length)
        let uriStringNoPrefix: String = String(uriString[index...])
        encodedUri += Array(uriStringNoPrefix.utf8)
        
        self.init(timeout: timeout, readProtection: readProtection, password: Array(passwordString.utf8),
                  content: encodedUri)
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count > 6 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        timeout = payload[0]
        
        let protectionMode = Ntag21xProtectionMode(rawValue: payload[1])
        if let protectionModeUnwrapped = protectionMode {
            self.passwordProtection = protectionModeUnwrapped
        } else {
            throw TCMPParsingError.invalidPasswordProtectionMode
        }
        
        let passwordLengthData = Data(Array(payload[2...3]))
        let passwordLength: Int = Int(UInt16(bigEndian: passwordLengthData.withUnsafeBytes { $0.pointee }))
        
        guard (4 + passwordLength) < payload.count else {
            throw TCMPParsingError.payloadTooShort
        }
        password = Array(payload[4..<(4 + passwordLength)])
        
        // skip two content length bytes
        let contentStartIndex = passwordLength + 6
        guard contentStartIndex < payload.count else {
            throw TCMPParsingError.payloadTooShort
        }
        content = Array(payload[contentStartIndex...])
    }
    
}
