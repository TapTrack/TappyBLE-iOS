//
//  SystemCommandFamilyConstants.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-12.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

// Mark: - System command & response codes

@objc public enum SystemCommandCode: UInt8 {
    case getHardwareVersion = 0xFE
    case getFirmwareVersion = 0xFF
    case pingTappy = 0xFD
    case setConfiguration = 0x01
    case getBatteryLevel = 0x02
    case outputTestFrames = 0x03
}

@objc public enum SystemResponseCode: UInt8 {
    // system communication errors
    case invalidMessage = 0x01
    case lcsError = 0x02 // length checksum error
    case crcError = 0x03
    case badLengthParameter = 0x04
    
    // response codes
    case getHardwareVersion = 0x05
    case getFirmwareVersion = 0x06
    case pingTappy = 0xFD
    case setConfiguration = 0x07
    case getBatteryLevel = 0x08
    case outputTestFrames = 0x09
    case error = 0x7F
}


// Mark - Configuration setting codes (for command code 0x01)

@objc public enum ConfigurationSettingCode: UInt8 {
    case setType2TagIdentification = 0x01
    case enableDataThrottling = 0x02
    case enableType1NdefWrite = 0x03
    
    // for successful scans
    case setAudibleBuzzer = 0x05
    case setGreenLedDuration = 0x06
    
    // for failed scans
    case setRedLedDuration = 0x07
}


// MARK: - System application error codes (for response code 0x7F)

@objc public enum SystemApplicationErrorCode: UInt8 {
    case invalidParameter = 0x05
    case unsupportedCommandFamily = 0x06
    case tooFewParameters = 0x07
}
