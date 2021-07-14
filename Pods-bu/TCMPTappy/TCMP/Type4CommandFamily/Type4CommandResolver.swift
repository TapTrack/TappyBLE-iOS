//
//  Type4CommandResolver.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

@objc public final class Type4CommandResolver: NSObject, MessageResolver {
    
    @objc private static func assertFamilyMatches(message: TCMPMessage) throws {
        if message.commandFamily != CommandFamily.type4 {
            throw TCMPParsingError.resolverError(errorDescription: "Specified message is for a different command family. Expected Type 4 command family, got \(bytesToHexString(message.commandFamily)).")
        }
    }
    
    @objc public static func resolveCommand(message: TCMPMessage) throws -> TCMPMessage {
        try assertFamilyMatches(message: message)
        var command: TCMPMessage
        
        switch message.commandCode {
            case Type4CommandCode.detectType4ATag.rawValue:
                command = try DetectType4ATagCommand(payload: message.payload)
            case Type4CommandCode.detectType4BTag.rawValue:
                command = try DetectType4BTagCommand(payload: message.payload)
            case Type4CommandCode.detectType4BTagWithAFI.rawValue:
                command = try DetectType4BTagWithAFICommand(payload: message.payload)
            case Type4CommandCode.transceiveAPDU.rawValue:
                command = try TransceiveAPDUCommand(payload: message.payload)
            case Type4CommandCode.getCommandFamilyVersion.rawValue:
                command = GetType4CommandFamilyVersionCommand()
            default:
                throw TCMPParsingError.resolverError(errorDescription: "Command not recognized by Type 4 command resolver. Command code: \(String(format: "%02X", message.commandCode))")
        }
        
        return command
    }
    
    @objc public static func resolveResponse(message: TCMPMessage) throws -> TCMPMessage {
        try assertFamilyMatches(message: message)
        var response: TCMPMessage
        
        switch message.commandCode {
            case Type4ResponseCode.type4ATagDetected.rawValue:
                response = try Type4ATagDetectedResponse(payload: message.payload)
            case Type4ResponseCode.transceiveAPDUSuccess.rawValue:
                response = try TransceiveAPDUSuccessResponse(payload: message.payload)
            case Type4ResponseCode.timeout.rawValue:
                response = DetectType4TimeoutResponse()
            case Type4ResponseCode.pollingErrorDetected.rawValue:
                response = Type4PollingErrorDetectedResponse()
            case Type4ResponseCode.commandFamilyVersion.rawValue:
                response = try GetType4CommandFamilyVersionResponse(payload: message.payload)
            case Type4ResponseCode.type4BTagDetected.rawValue:
                response = try Type4BTagDetectedResponse(payload: message.payload)
            case Type4ResponseCode.error.rawValue:
                response = try Type4ApplicationErrorResponse(payload: message.payload)
            default:
                throw TCMPParsingError.resolverError(errorDescription: "Response not recognized by Type 4 response resolver. Response code: \(String(format: "%02X", message.commandCode))")
        }
        
        return response
    }
}
