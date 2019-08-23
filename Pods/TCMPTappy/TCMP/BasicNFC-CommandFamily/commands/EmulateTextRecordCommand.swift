//
//  EmulateTextRecordCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


// note that this assumes english and utf8
@objc public class EmulateTextRecordCommand: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.basicNFC
    
    @objc public let commandCode: UInt8 = BasicNFCCommandCode.emulateTextRecord.rawValue
    
    @objc public private(set) var timeout: UInt8 = 0x00
    @objc public private(set) var maxScans: UInt8 = 0x00
    @objc public private(set) var text: [UInt8] = []
    
    @objc public var textString: String {
        get {
            let _textString = String(bytes: text, encoding: .utf8)
            return (_textString != nil) ? _textString! : ""
        }
    }
    
    @objc public var payload: [UInt8] {
        get {
            return [timeout] + [maxScans] + text
        }
    }
    
    @objc public init(timeout: UInt8, maxScans: UInt8, text: [UInt8]) {
        super.init()
        
        self.timeout = timeout
        self.maxScans = maxScans
        self.text = text
    }

    @objc public convenience init(timeout: UInt8, maxScans: UInt8, textString: String) {
        self.init(timeout: timeout, maxScans: maxScans, text: Array(textString.utf8))
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 2 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        timeout = payload[0]
        maxScans = payload[1]
        if payload.count > 2 {
            text = Array(payload[2...])
        }
    }
    
}
