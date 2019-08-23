//
//  OutputTestFramesResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-09.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class OutputTestFramesResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.system
    
    @objc public let commandCode: UInt8 = SystemResponseCode.outputTestFrames.rawValue
    
    @objc public private(set) var dummyBytes: [UInt8] = []
    
    @objc public var payload: [UInt8] {
        get {
            return dummyBytes
        }
    }

    
    @objc public init (payload: [UInt8]) throws {
        super.init();
        dummyBytes = payload
    }
    
    
    @objc public func parsePayload(payload: [UInt8]) throws { }
    
}
