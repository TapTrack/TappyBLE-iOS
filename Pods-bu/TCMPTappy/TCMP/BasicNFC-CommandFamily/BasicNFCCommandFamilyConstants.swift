//
//  BasicNFCCommandFamilyConstants.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-12.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

// MARK: - Basic NFC Commands & Responses

@objc public enum BasicNFCCommandCode: UInt8 {
    case stop = 0x00
    case getCommandFamilyVersion = 0xFF
    case lockTag = 0x08
    
    case streamTag = 0x01
    case scanTag = 0x02
    
    case streamNDEFMessage = 0x03
    case scanNDEFMessage = 0x04
    
    case writeURIRecord = 0x05
    case writeTextRecord = 0x06
    case writeCustomMessage = 0x07
    
    case streamTagDispatch = 0x0C
    case singleTagDispatch = 0x0F
    
    case detectTagUIDWithRestriction = 0x0D
    case streamTagUIDWithRestriction = 0x0E
    
    case startAutoPolling = 0x10
    
    case emulateURIRecord = 0x0A
    case emulateTextRecord = 0x09
    case emulateCustomNDEFRecord = 0x0B
}

@objc public enum BasicNFCResponseCode: UInt8 {
    case tagFound = 0x01
    case ndefFound = 0x02
    
    case timeout = 0x03
    case commandFamilyVersion = 0x04
    case tagWritten = 0x05
    
    case autoPollingTagEntry = 0x0C
    case autoPollingTagExit = 0x0D
    
    case emulationSuccess = 0x07
    case emulationStopped = 0x08
    
    case error = 0x7F
}


// MARK: - BasicNFC Application Errors (response code 0x7F)

@objc public enum BasicNFCErrorCode: UInt8 {
    case invalidParameter = 0x01
    case reservedForFutureUse = 0x02
    case pollingError = 0x03
    case tooFewParameters = 0x04
    case ndefMessageExceedsTagStorage = 0x05
    case errorCreatingNDEFContent = 0x06
    case errorWritingNDEFDataToTag = 0x07
    case errorLockingTag = 0x08
    case unsupportedCommandCode = 0x09
}


// MARK: - Auto Polling

@objc public enum AutoPollingScanMode: UInt8 {
    case detectType2 = 0x00
    case detectType1 = 0x01
    case detectTypeISO144414B = 0x02
    case detectFeliCa = 0x03
    case detectType4A = 0x04
    case detectAll = 0x05
}

@objc public enum AutoPollingTagType: UInt8 {
    case type2 = 0x00
    case type1 = 0x01
    case typeISO144414B = 0x02
    case feliCa = 0x03
    case type4A = 0x04
    case unrecognized = 0x05
}

// MARK: - NDEF Tag Emulation

@objc public enum NDEFEmulationStopCode: UInt8 {
    case timeoutReached = 0x01
    case maximumScansReached = 0x02
    case newTCMPFrameReceived = 0x03
}
