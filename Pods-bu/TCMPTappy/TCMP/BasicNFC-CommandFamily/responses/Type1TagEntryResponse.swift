//
//  Type1TagEntryResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-08.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class Type1TagEntryResponse: NSObject, TCMPMessage, AutoPollingType1TagResponse {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.basicNFC
    @objc public let commandCode: UInt8 = BasicNFCResponseCode.autoPollingTagEntry.rawValue
    
    @objc public let tagType: UInt8 = AutoPollingTagType.type1.rawValue
    
    @objc public private(set) var sensRes: [UInt8] = []
    @objc public private(set) var selRes: UInt8 = 0x00
    @objc public private(set) var uid: [UInt8] = []
    @objc public private(set) var ats: [UInt8] = []
    
    @objc public var tagMetadata: [UInt8] {
        get {
            return sensRes + uid
        }
    }
    
    @objc public var payload: [UInt8] {
        get {
            return [tagType] + tagMetadata
        }
    }
    
    @objc public required init(tagMetadata: [UInt8]) throws {
        super.init()
        
        let parsedMetadata: (sensRes: [UInt8], uid: [UInt8]) =
            try parseTagMetadata(metadata: tagMetadata)
        
        self.sensRes = parsedMetadata.sensRes
        self.uid = parsedMetadata.uid
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws { }
    
}

