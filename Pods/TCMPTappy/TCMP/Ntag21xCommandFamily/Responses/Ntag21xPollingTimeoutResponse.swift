//
//  Ntag21xPollingTimeoutResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-19.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class Ntag21xPollingTimeoutResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.ntag21x
    
    @objc public let commandCode: UInt8 = Ntag21xResponseCode.pollingTimeout.rawValue
    
    @objc public private(set) var payload: [UInt8] = []
    
    @objc public func parsePayload(payload: [UInt8]) throws { }
    
}
