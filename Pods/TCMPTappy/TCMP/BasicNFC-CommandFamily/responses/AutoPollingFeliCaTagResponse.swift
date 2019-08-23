//
//  AutoPollingFeliCaTagResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-09.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public protocol AutoPollingFeliCaTagResponse {
    
    @objc var commandFamily: [UInt8] { get }
    @objc var commandCode: UInt8 { get }
    @objc var tagType: UInt8 { get }
    
    @objc var pollResLength: UInt8 { get }
    @objc var responseCode: UInt8 { get }
    @objc var uid: [UInt8] { get }
    @objc var pad: [UInt8] { get }
    @objc var systCode: [UInt8] { get }
    
    @objc init(tagMetadata: [UInt8]) throws
}

public extension AutoPollingFeliCaTagResponse {
    func parseTagMetadata(metadata: [UInt8]) throws -> (UInt8, UInt8, [UInt8], [UInt8], [UInt8]) {
        guard metadata.count >= 18 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        let pollResLength: UInt8 = metadata[0]
        let responseCode: UInt8 = metadata[1]
        let uid: [UInt8] = Array(metadata[2..<10]) // always 8 bytes
        let pad: [UInt8] = Array(metadata[10..<18]) // always 8 bytes
        
        var systCode: [UInt8] = []
        if metadata.count >= 20 {
            // Optional two bytes at end of payload is system code.
            systCode = Array(metadata[18..<20])
        }
        
        return (pollResLength, responseCode, uid, pad, systCode)
    }
}
