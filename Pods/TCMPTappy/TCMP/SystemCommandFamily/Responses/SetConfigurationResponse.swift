//
//  SetConfigurationResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-08.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class SetConfigurationResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.system
    
    @objc public let commandCode: UInt8 = SystemResponseCode.setConfiguration.rawValue
    
    @objc public private(set) var payload: [UInt8] = []
    
    @objc public func parsePayload(payload: [UInt8]) throws {}
    
}
