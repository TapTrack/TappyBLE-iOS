//
//  TypeISO14443BTagExitResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-09.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class TypeISO14443BTagExitResponse: NSObject, TCMPMessage, AutoPollingTypeISO14443BTagResponse {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.basicNFC
    @objc public let commandCode: UInt8 = BasicNFCResponseCode.autoPollingTagExit.rawValue
    
    @objc public let tagType: UInt8 = AutoPollingTagType.typeISO144414B.rawValue
    
    @objc public private(set) var atqb: [UInt8] = []
    @objc public private(set) var attribRes: [UInt8] = []
    
    @objc public var tagMetadata: [UInt8] {
        get {
            return atqb + attribRes
        }
    }
    
    @objc public var payload: [UInt8] {
        get {
            return [tagType] + tagMetadata
        }
    }
    
    @objc public required init(tagMetadata: [UInt8]) throws {
        super.init()
        
        let parsedMetadata: (atqb: [UInt8], attribRes: [UInt8]) =
            try parseTagMetadata(metadata: tagMetadata)
        
        self.atqb = parsedMetadata.atqb
        self.attribRes = parsedMetadata.attribRes
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws { }
    
}
