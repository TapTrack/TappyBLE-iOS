//
//  Type4CommandFamilyConstants.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

// MARK: - Type 4 Commands & Responses

@objc public enum Type4CommandCode: UInt8 {
    case detectType4ATag = 0x01
    case detectType4BTag = 0x03
    case detectType4BTagWithAFI = 0x04
    
    case transceiveAPDU = 0x02
    case getCommandFamilyVersion = 0xFF
}

@objc public enum Type4ResponseCode: UInt8 {
    case type4ATagDetected = 0x01
    case type4BTagDetected = 0x07
    
    case transceiveAPDUSuccess = 0x02
    case timeout = 0x03
    case pollingErrorDetected = 0x04
    case commandFamilyVersion = 0x05
    
    case error = 0x7F
}


// MARK: - Type 4 Application Errors (response code 0x7F)

@objc public enum Type4ErrorCode: UInt8 {
    case tooFewParameters = 0x01
    case tooManyParameters = 0x02
    case transceiveError = 0x03
    case invalidParameter = 0x04
    case noTagPresent = 0x05
    case nfcReaderChipError = 0x06
}
