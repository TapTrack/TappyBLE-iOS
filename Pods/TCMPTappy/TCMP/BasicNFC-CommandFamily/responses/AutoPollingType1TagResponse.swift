//
//  AutoPollingType1TagResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-09.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public protocol AutoPollingType1TagResponse {
    
    @objc var commandFamily: [UInt8] { get }
    @objc var commandCode: UInt8 { get }
    @objc var tagType: UInt8 { get }
    
    @objc var sensRes: [UInt8] { get }
    @objc var uid: [UInt8] { get }
    
    @objc init(tagMetadata: [UInt8]) throws
}

public extension AutoPollingType1TagResponse {
    func parseTagMetadata(metadata: [UInt8]) throws -> ([UInt8], [UInt8]) {
        guard metadata.count > 5 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        let sensRes: [UInt8] = Array(metadata[0...1])
        
        // UID is the last four bytes of the payload
        let uid: [UInt8] = Array(metadata[2...5])
        
        return (sensRes, uid)
    }
}
