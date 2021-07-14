//
//  Ntag21xCommandResolver.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-19.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

@objc public final class Ntag21xCommandResolver: NSObject, MessageResolver {
    
    @objc private static func assertFamilyMatches(message: TCMPMessage) throws {
        if message.commandFamily != CommandFamily.ntag21x {
            throw TCMPParsingError.resolverError(errorDescription: "Specified message is for a different command family. Expected NTAG 21x command family, got \(bytesToHexString(message.commandFamily)).")
        }
    }
    
    @objc public static func resolveCommand(message: TCMPMessage) throws -> TCMPMessage {
        try assertFamilyMatches(message: message)
        var command: TCMPMessage
        
        switch message.commandCode {
            case Ntag21xCommandCode.writeTextNdefWithPassword.rawValue:
                command = try WriteTextNdefWithPasswordCommand(payload: message.payload)
            case Ntag21xCommandCode.writeUriNdefWithPassword.rawValue:
                command = try WriteUriNdefWithPasswordCommand(payload: message.payload)
            case Ntag21xCommandCode.writeCustomNdefWithPassword.rawValue:
                command = try WriteCustomNDEFWithPasswordCommand(payload: message.payload)
            case Ntag21xCommandCode.readNdefFromPasswordProtectedTag.rawValue:
                command = try ReadNdefWithPasswordCommand(payload: message.payload)
            case Ntag21xCommandCode.writeTextNdefWithPasswordBytes.rawValue:
                command = try WriteTextNdefWithPasswordBytesCommand(payload: message.payload)
            case Ntag21xCommandCode.writeUriNdefWithPasswordBytes.rawValue:
                command = try WriteUriNdefWithPasswordBytesCommand(payload: message.payload)
            case Ntag21xCommandCode.writeCustomNdefWithPasswordBytes.rawValue:
                command = try WriteCustomNdefWithPasswordBytesCommand(payload: message.payload)
            case Ntag21xCommandCode.readNdefFromPasswordProtectedTagWithPasswordBytes.rawValue:
                command = try ReadNdefWithPasswordBytesCommand(payload: message.payload)
            case Ntag21xCommandCode.getCommandFamilyVersion.rawValue:
                command = GetNtag21xCommandFamilyVersionCommand()
            default:
                throw TCMPParsingError.resolverError(errorDescription: "Command not recognized by NTAG 21x command resolver. Command code: \(String(format: "%02X", message.commandCode))")
        }
        
        return command
    }
    
    @objc public static func resolveResponse(message: TCMPMessage) throws -> TCMPMessage {
        try assertFamilyMatches(message: message)
        var response: TCMPMessage
        
        switch message.commandCode {
            case Ntag21xResponseCode.readSuccess.rawValue:
                response = try Ntag21xReadSuccessResponse(payload: message.payload)
            case Ntag21xResponseCode.pollingTimeout.rawValue:
                response = Ntag21xPollingTimeoutResponse()
            case Ntag21xResponseCode.commandFamilyVersion.rawValue:
                response = try GetNtag21xCommandFamilyVersionResponse(payload: message.payload)
            case Ntag21xResponseCode.writeSuccess.rawValue:
                response = try Ntag21xWriteSuccessResponse(payload: message.payload)
            case Ntag21xResponseCode.error.rawValue:
                response = try Ntag21xApplicationErrorResponse(payload: message.payload)
            default:
                throw TCMPParsingError.resolverError(errorDescription: "Response not recognized by NTAG 21x response resolver. Response code: \(String(format: "%02X", message.commandCode))")
        }
        
        return response
    }
}
