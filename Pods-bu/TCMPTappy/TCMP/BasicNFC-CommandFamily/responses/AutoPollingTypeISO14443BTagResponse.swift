//
//  AutoPollingTypeISO14443BTagResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-09.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public protocol AutoPollingTypeISO14443BTagResponse {
    
    @objc var commandFamily: [UInt8] { get }
    @objc var commandCode: UInt8 { get }
    @objc var tagType: UInt8 { get }
    
    @objc var atqb: [UInt8] { get }
    @objc var attribRes: [UInt8] { get }
    
    @objc init(tagMetadata: [UInt8]) throws
}

public extension AutoPollingTypeISO14443BTagResponse {
    func parseTagMetadata(metadata: [UInt8]) throws -> ([UInt8], [UInt8]) {
        guard metadata.count > 13 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        // ATQB is always the first twelve bytes of tag metadata.
        let atqb: [UInt8] = Array(metadata[0..<12])
        
        let attribResLength: Int = Int(metadata[12])
        let attribRes: [UInt8] = Array(metadata[13..<(13 + attribResLength)])
        
        return (atqb, attribRes)
    }
}
