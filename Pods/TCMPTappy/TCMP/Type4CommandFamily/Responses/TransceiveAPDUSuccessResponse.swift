//
//  TransceiveAPDUSuccessResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class TransceiveAPDUSuccessResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.type4
    
    @objc public let commandCode: UInt8 = Type4ResponseCode.transceiveAPDUSuccess.rawValue
    
    // Bytes returned from tag
    @objc public private(set) var returnedBytes: [UInt8] = []
    
    @objc public var payload: [UInt8] {
        get {
            return returnedBytes
        }
    }
    
    @objc public required init(payload: [UInt8]) throws {
        super.init()
        returnedBytes = payload
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws { }
    
}
