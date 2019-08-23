//
//  PingResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-07.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class PingResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.system
    
    @objc public let commandCode: UInt8 = SystemResponseCode.pingTappy.rawValue
    
    @objc public private(set) var payload: [UInt8] = []
    
    @objc public func parsePayload(payload: [UInt8]) throws {}
    
}
