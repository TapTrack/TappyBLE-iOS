//
//  EmulationSuccessResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class EmulationSuccessResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.basicNFC
    
    @objc public let commandCode: UInt8 = BasicNFCResponseCode.emulationSuccess.rawValue
    
    @objc public private(set) var payload: [UInt8] = []
    
    @objc public func parsePayload(payload: [UInt8]) throws { }
    
}
