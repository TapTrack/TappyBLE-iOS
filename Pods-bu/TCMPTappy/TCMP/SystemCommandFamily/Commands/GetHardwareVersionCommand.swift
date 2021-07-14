//
//  GetHardwareVersionCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-07.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class GetHardwareVersionCommand: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.system
    
    @objc public let commandCode: UInt8 = SystemCommandCode.getHardwareVersion.rawValue
    
    @objc public var payload: [UInt8] = []
    
    @objc public func parsePayload(payload: [UInt8]) throws {}
}
