//
//  GetType4CommandFamilyVersionCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class GetType4CommandFamilyVersionCommand: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.type4
    
    @objc public let commandCode: UInt8 = Type4CommandCode.getCommandFamilyVersion.rawValue
    
    @objc public var payload: [UInt8] = []
    
    @objc public func parsePayload(payload: [UInt8]) throws {}
    
}
