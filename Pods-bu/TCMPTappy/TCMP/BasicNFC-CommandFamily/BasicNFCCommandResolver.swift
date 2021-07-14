//
//  BasicNFCCommandResolver.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-09.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

@objc public final class BasicNFCCommandResolver: NSObject, MessageResolver {
    
    @objc private static func assertFamilyMatches(message: TCMPMessage) throws {
        if message.commandFamily != CommandFamily.basicNFC {
            throw TCMPParsingError.resolverError(errorDescription: "Specified message is for a different command family. Expected Basic NFC command family, got \(bytesToHexString(message.commandFamily)).")
        }
    }
    
    @objc public static func resolveCommand(message: TCMPMessage) throws -> TCMPMessage {
        try assertFamilyMatches(message: message)
        var command: TCMPMessage
        
        switch message.commandCode {
        case BasicNFCCommandCode.stop.rawValue:
            command = StopCommand()
        case BasicNFCCommandCode.streamTag.rawValue:
            command = try StreamTagCommand(payload: message.payload)
        case BasicNFCCommandCode.scanTag.rawValue:
            command = try ScanTagCommand(payload: message.payload)
        case BasicNFCCommandCode.streamNDEFMessage.rawValue:
            command = try StreamNDEFCommand(payload: message.payload)
        case BasicNFCCommandCode.scanNDEFMessage.rawValue:
            command = try ScanNDEFCommand(payload: message.payload)
        case BasicNFCCommandCode.writeURIRecord.rawValue:
            command = try WriteNDEFUriCommand(payload: message.payload)
        case BasicNFCCommandCode.writeTextRecord.rawValue:
            command = try WriteNDEFTextCommand(payload: message.payload)
        case BasicNFCCommandCode.writeCustomMessage.rawValue:
            command = try WriteCustomNDEFCommand(payload: message.payload)
        case BasicNFCCommandCode.startAutoPolling.rawValue:
            command = try AutoPollingCommand(payload: message.payload)
        case BasicNFCCommandCode.emulateURIRecord.rawValue:
            command = try EmulateURIRecordCommand(payload: message.payload)
        case BasicNFCCommandCode.emulateTextRecord.rawValue:
            command = try EmulateTextRecordCommand(payload: message.payload)
        case BasicNFCCommandCode.emulateCustomNDEFRecord.rawValue:
            command = try EmulateCustomNDEFRecordCommand(payload: message.payload)
        default:
            throw TCMPParsingError.resolverError(errorDescription: "Command not recognized by Basic NFC command resolver. Command code: \(String(format: "%02X", message.commandCode))")
        }
        
        return command
    }
    
    @objc public static func resolveResponse(message: TCMPMessage) throws -> TCMPMessage {
        try assertFamilyMatches(message: message)
        var response: TCMPMessage
        
        switch message.commandCode {
        case BasicNFCResponseCode.error.rawValue:
            response = try BasicNfcApplicationErrorMessage(payload: message.payload)
        case BasicNFCResponseCode.tagWritten.rawValue:
            response = try TagWrittenResponse(payload: message.payload)
        case BasicNFCResponseCode.ndefFound.rawValue:
            response = try NDEFFoundResponse(payload: message.payload)
        case BasicNFCResponseCode.tagFound.rawValue:
            response = try TagFoundResponse(payload: message.payload)
        case BasicNFCResponseCode.autoPollingTagEntry.rawValue:
            response = try resolveAutoPollingTagEntry(message: message)
        case BasicNFCResponseCode.autoPollingTagExit.rawValue:
            response = try resolveAutoPollingTagExit(message: message)
        case BasicNFCResponseCode.emulationSuccess.rawValue:
            response = EmulationSuccessResponse()
        case BasicNFCResponseCode.emulationStopped.rawValue:
            response = try EmulationStoppedResponse(payload: message.payload)
        default:
            throw TCMPParsingError.resolverError(errorDescription: "Response not recognized by Basic NFC response resolver. Response code: \(String(format: "%02X", message.commandCode))")
        }
        
        return response
    }
    
    @objc private static func resolveAutoPollingTagEntry(message: TCMPMessage) throws -> TCMPMessage {
        let tagType: UInt8 = message.payload[0]
        let tagMetadata: [UInt8] = Array(message.payload[1...])
        var response: TCMPMessage
        
        switch tagType {
        case AutoPollingTagType.type2.rawValue:
            response = try Type2TagEntryResponse(tagMetadata: tagMetadata)
        case AutoPollingTagType.type1.rawValue:
            response = try Type1TagEntryResponse(tagMetadata: tagMetadata)
        case AutoPollingTagType.typeISO144414B.rawValue:
            response = try TypeISO14443BTagEntryResponse(tagMetadata: tagMetadata)
        case AutoPollingTagType.feliCa.rawValue:
            response = try FeliCaTagEntryResponse(tagMetadata: tagMetadata)
        case AutoPollingTagType.type4A.rawValue:
            response = try Type4ATagEntryResponse(tagMetadata: tagMetadata)
        default:
            response = UnrecognizedTagEntryResponse(tagMetadata: tagMetadata)
        }
        
        return response
    }
    
    @objc private static func resolveAutoPollingTagExit(message: TCMPMessage) throws -> TCMPMessage {
        let tagType: UInt8 = message.payload[0]
        let tagMetadata: [UInt8] = Array(message.payload[1...])
        var response: TCMPMessage
        
        switch tagType {
        case AutoPollingTagType.type2.rawValue:
            response = try Type2TagExitResponse(tagMetadata: tagMetadata)
        case AutoPollingTagType.type1.rawValue:
            response = try Type1TagExitResponse(tagMetadata: tagMetadata)
        case AutoPollingTagType.typeISO144414B.rawValue:
            response = try TypeISO14443BTagExitResponse(tagMetadata: tagMetadata)
        case AutoPollingTagType.feliCa.rawValue:
            response = try FeliCaTagExitResponse(tagMetadata: tagMetadata)
        case AutoPollingTagType.type4A.rawValue:
            response = try Type4ATagExitResponse(tagMetadata: tagMetadata)
        default:
            response = UnrecognizedTagExitResponse(tagMetadata: tagMetadata)
        }
        
        return response
    }
}

