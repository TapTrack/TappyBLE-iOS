//
//  ReadNdefWithPasswordBytesCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-16.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class ReadNdefWithPasswordBytesCommand: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.ntag21x
    
    @objc public let commandCode: UInt8 = Ntag21xCommandCode.readNdefFromPasswordProtectedTagWithPasswordBytes.rawValue
    
    @objc public private(set) var timeout: UInt8 = 0x00
    
    @objc public private(set) var password: [UInt8] = []
    
    @objc public private(set) var passwordAcknowledgement: [UInt8] = []
    
    @objc public var payload: [UInt8] {
        get {
            return [timeout] + password + passwordAcknowledgement
        }
    }
    
    @objc public init?(timeout: UInt8, password: [UInt8], passwordAcknowledgement: [UInt8]) {
        super.init()
        
        guard password.count == 4 else {
            NSLog("Password must be four bytes long.")
            return nil
        }
        guard passwordAcknowledgement.count == 2 else {
            NSLog("Password acknowledgement must be two bytes long.")
            return nil
        }
        
        self.timeout = timeout
        self.password = password
        self.passwordAcknowledgement = password
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 7 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        timeout = payload[0]
        password = Array(payload[1...4])
        passwordAcknowledgement = Array(payload[5...6])
    }
}
