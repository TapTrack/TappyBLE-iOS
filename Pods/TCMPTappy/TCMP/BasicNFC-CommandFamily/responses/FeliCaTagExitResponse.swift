 //
//  FeliCaTagExitResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-09.
//  Copyright © 2019 TapTrack. All rights reserved.
//

 import Foundation
 
 
 @objc public class FeliCaTagExitResponse: NSObject, TCMPMessage, AutoPollingFeliCaTagResponse {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.basicNFC
    @objc public let commandCode: UInt8 = BasicNFCResponseCode.autoPollingTagExit.rawValue
    
    @objc public let tagType: UInt8 = AutoPollingTagType.feliCa.rawValue
    
    @objc public private(set) var pollResLength: UInt8 = 0x00
    @objc public private(set) var responseCode: UInt8 = 0x00
    @objc public private(set) var uid: [UInt8] = []
    @objc public private(set) var pad: [UInt8] = []
    @objc public private(set) var systCode: [UInt8] = []

    @objc public var tagMetadata: [UInt8] {
        get {
            return [pollResLength] + [responseCode] + uid + pad + systCode
        }
    }

    @objc public var payload: [UInt8] {
        get {
            return [tagType] + tagMetadata
        }
    }
    
    @objc public required init(tagMetadata: [UInt8]) throws {
        super.init()
        
        let parsedMetadata: (
            pollResLength: UInt8,
            responseCode: UInt8,
            uid: [UInt8],
            pad: [UInt8],
            systCode: [UInt8]
            ) = try parseTagMetadata(metadata: tagMetadata)
        
        self.pollResLength = parsedMetadata.pollResLength
        self.responseCode = parsedMetadata.responseCode
        self.uid = parsedMetadata.uid
        self.pad = parsedMetadata.pad
        self.systCode = parsedMetadata.systCode
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws { }
    
 }
