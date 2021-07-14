//
//  SystemCommandResolver.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-07.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

@objc public final class SystemCommandResolver: NSObject, MessageResolver {
    
    @objc private static func assertFamilyMatches(message: TCMPMessage) throws {
        if message.commandFamily != CommandFamily.system {
            throw TCMPParsingError.resolverError(errorDescription: "Specified message is for a different command family. Expected system command family, got \(bytesToHexString(message.commandFamily)).")
        }
    }
    
    @objc public static func resolveCommand(message: TCMPMessage) throws -> TCMPMessage {
        try assertFamilyMatches(message: message)
        var command: TCMPMessage
        
        switch message.commandCode {
            case SystemCommandCode.getFirmwareVersion.rawValue:
                command = GetFirmwareVersionCommand()
            case SystemCommandCode.getHardwareVersion.rawValue:
                command = GetHardwareVersionCommand()
            case SystemCommandCode.pingTappy.rawValue:
                command = PingCommand()
            case SystemCommandCode.setConfiguration.rawValue:
                command = try SetConfigurationCommand(payload: message.payload)
            case SystemCommandCode.getBatteryLevel.rawValue:
                command = GetBatteryLevelCommand()
            case SystemCommandCode.outputTestFrames.rawValue:
                command = try OutputTestFramesCommand(payload: message.payload)
            default:
                throw TCMPParsingError.resolverError(errorDescription: "Command not recognized by system command resolver. Command code: \(String(format: "%02X", message.commandCode))")
        }
        
        return command
    }
    
    @objc public static func resolveResponse(message: TCMPMessage) throws -> TCMPMessage {
        try assertFamilyMatches(message: message)
        var response: TCMPMessage
        
        switch message.commandCode {
            case SystemResponseCode.getFirmwareVersion.rawValue:
                response = try GetFirmwareVersionResponse(payload: message.payload)
            case SystemResponseCode.getHardwareVersion.rawValue:
                response = try GetHardwareVersionResponse(payload: message.payload)
            case SystemResponseCode.getBatteryLevel.rawValue:
                response = try GetBatteryLevelResponse(payload: message.payload)
            case SystemResponseCode.pingTappy.rawValue:
                response = PingResponse()
            case SystemResponseCode.setConfiguration.rawValue:
                response = SetConfigurationResponse()
            case SystemResponseCode.outputTestFrames.rawValue:
                response = try OutputTestFramesResponse(payload: message.payload)
            case SystemResponseCode.invalidMessage.rawValue:
                response = try SystemErrorResponse(responseCode: SystemResponseCode.invalidMessage)
            case SystemResponseCode.lcsError.rawValue:
                response = try SystemErrorResponse(responseCode: SystemResponseCode.lcsError)
            case SystemResponseCode.crcError.rawValue:
                response = try SystemErrorResponse(responseCode: SystemResponseCode.crcError)
            case SystemResponseCode.badLengthParameter.rawValue:
                response = try SystemErrorResponse(responseCode: SystemResponseCode.badLengthParameter)
            case SystemResponseCode.error.rawValue:
                response = try SystemApplicationErrorResponse(payload: message.payload)
            default:
                throw TCMPParsingError.resolverError(errorDescription: "Response not recognized by system response resolver. Response code: \(String(format: "%02X", message.commandCode))")
        }
        
        return response
    }
}
