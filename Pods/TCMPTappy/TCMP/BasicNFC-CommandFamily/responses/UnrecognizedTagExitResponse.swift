//
//  UnrecognizedTagExitEvent.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-12.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class UnrecognizedTagExitResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.basicNFC
    
    @objc public let commandCode: UInt8 = BasicNFCResponseCode.autoPollingTagExit.rawValue
    
    @objc public let tagType: UInt8 = AutoPollingTagType.unrecognized.rawValue
    
    @objc public private(set) var tagMetadata: [UInt8] = []
    
    @objc public var payload: [UInt8] {
        get {
            return [tagType] + tagMetadata
        }
    }
    
    @objc public required init(tagMetadata: [UInt8]) {
        super.init()
        
        self.tagMetadata = tagMetadata
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws { }
    
}
