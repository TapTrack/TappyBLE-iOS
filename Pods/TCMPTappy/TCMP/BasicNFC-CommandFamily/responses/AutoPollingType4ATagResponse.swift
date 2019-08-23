//
//  AutoPollingType4ATagResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-09.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public protocol AutoPollingType4ATagResponse {
    
    @objc var commandFamily: [UInt8] { get }
    @objc var commandCode: UInt8 { get }
    @objc var tagType: UInt8 { get }
    
    @objc var sensRes: [UInt8] { get }
    @objc var selRes: UInt8 { get }
    @objc var uid: [UInt8] { get }
    @objc var ats: [UInt8] { get }

    @objc init(tagMetadata: [UInt8]) throws
}

public extension AutoPollingType4ATagResponse {
    func parseTagMetadata(metadata: [UInt8]) throws -> ([UInt8], UInt8, [UInt8], [UInt8]) {
        guard metadata.count > 5 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        let sensRes: [UInt8] = Array(metadata[0...1])
        let selRes: UInt8 = metadata[2]
        
        let uidLength: Int = Int(metadata[3])
        let uid: [UInt8] = Array(metadata[4..<(4 + uidLength)])
        
        let ats: [UInt8] = Array(metadata[(4 + uidLength)...])
        
        return (sensRes, selRes, uid, ats)
    }
}
