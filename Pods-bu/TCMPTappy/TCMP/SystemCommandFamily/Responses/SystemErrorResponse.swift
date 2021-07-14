//
//  SystemErrorResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-12.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class SystemErrorResponse: NSObject, TCMPMessage {
    
    @objc public private(set) var commandFamily: [UInt8] = CommandFamily.system
    
    @objc public private(set) var commandCode: UInt8 = 0x00
    
    @objc public private(set) var payload: [UInt8] = []
    
    @objc public init(responseCode: SystemResponseCode) throws {
        super.init()
        commandCode = responseCode.rawValue
    }
    
    @objc public func getErrorDescription() -> String {
        switch commandCode {
            case SystemResponseCode.invalidMessage.rawValue:
                return "Invalid message."
            case SystemResponseCode.lcsError.rawValue:
                return "Length checksum error."
            case SystemResponseCode.crcError.rawValue:
                return "CRC error."
            case SystemResponseCode.badLengthParameter.rawValue:
                return "Bad length parameter."
            default:
                return "System error."
        }
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {}
    
}
