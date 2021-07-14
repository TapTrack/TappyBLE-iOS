//
//  Ntag21xCommandFamilyConstants.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-16.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

// MARK: - NTAG Commands & Responses

@objc public enum Ntag21xCommandCode: UInt8 {
    case writeTextNdefWithPassword = 0x01
    case writeUriNdefWithPassword = 0x02
    case writeCustomNdefWithPassword = 0x03
    case readNdefFromPasswordProtectedTag = 0x04
    
    case writeTextNdefWithPasswordBytes = 0x05
    case writeUriNdefWithPasswordBytes = 0x06
    case writeCustomNdefWithPasswordBytes = 0x07
    case readNdefFromPasswordProtectedTagWithPasswordBytes = 0x08
    
    case getCommandFamilyVersion = 0xFF
}

@objc public enum Ntag21xResponseCode: UInt8 {
    case readSuccess = 0x01
    case pollingTimeout = 0x03
    case commandFamilyVersion = 0x04
    case writeSuccess = 0x05
    case error = 0x7F
}


// MARK: - NTAG read/write protection

@objc public enum Ntag21xProtectionMode: UInt8 {
    case writeProtection = 0x00
    case readAndWriteProtection = 0x01
}


// MARK: - NTAG Application Errors (response code 0x7F)

@objc public enum Ntag21xErrorCode: UInt8 {
    case invalidParameter = 0x01
    case pollingError = 0x02
    case tooFewParameters = 0x03
    case ndefMessageTooBigForTag = 0x04
    case errorCreatingNdefContent = 0x05
    case errorWritingNdefDataToTag = 0x06
    case errorSettingPassword = 0x07
    case passwordTooShort = 0x08
    case invalidCommandCode = 0x09
    case incompatibleTagDetected = 0x0A
    case errorAuthenticatingTagWithPassword = 0x0B
    case errorComputingPasswordBytes = 0x0C
    case passwordOrContentLengthsInvalid = 0x0D
    case errorReadingNdefMessageFromTag = 0x0E
}
