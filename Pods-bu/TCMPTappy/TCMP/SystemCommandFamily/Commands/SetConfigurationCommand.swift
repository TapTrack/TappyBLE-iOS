//
//  SetConfigurationCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-07.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class SetConfigurationCommand: NSObject, TCMPMessage {
    @objc public let commandFamily: [UInt8] = CommandFamily.system
    @objc public let commandCode: UInt8 = SystemCommandCode.setConfiguration.rawValue
    
    @objc public private(set) var configurationSettingCode: UInt8 = ConfigurationSettingCode.setType2TagIdentification.rawValue
    
    // If set to anything other than 0x00, the specified setting will be enabled.
    @objc public private(set) var enableSettingFlag: UInt8 = 0x00
    
    @objc public var payload: [UInt8] {
        get {
            return [configurationSettingCode] + [enableSettingFlag]
        }
    }
    
    @objc public init(configurationSettingCode: ConfigurationSettingCode, enable: Bool) {
        super.init()
        
        self.configurationSettingCode = configurationSettingCode.rawValue
        if enable {
            enableSettingFlag = 0x01
        }
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 2 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        configurationSettingCode = payload[0]
        enableSettingFlag = payload[1]
    }
}
