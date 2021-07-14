//
//  GetNtag21xCommandFamilyVersionCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-16.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class GetNtag21xCommandFamilyVersionCommand: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.ntag21x
    
    @objc public let commandCode: UInt8 = Ntag21xCommandCode.getCommandFamilyVersion.rawValue
    
    @objc public var payload: [UInt8] = []
    
    @objc public func parsePayload(payload: [UInt8]) throws {}
    
}
