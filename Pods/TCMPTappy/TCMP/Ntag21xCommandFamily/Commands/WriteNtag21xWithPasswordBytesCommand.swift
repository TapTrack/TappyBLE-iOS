//
//  WriteNtag21xWithPasswordBytesCommand.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-19.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

@objc public protocol WriteNtag21xWithPasswordBytesCommand {
    @objc var commandFamily: [UInt8] { get }
    @objc var commandCode: UInt8 { get }
    
    @objc var timeout: UInt8 { get }
    @objc var passwordProtection: Ntag21xProtectionMode { get }
    @objc var password: [UInt8] { get }
    @objc var passwordAcknowledgement: [UInt8] { get }
    @objc var content: [UInt8] { get }
    
    @objc init?(timeout: UInt8, readProtection: Bool, password: [UInt8],
          passwordAcknowledgement: [UInt8], content: [UInt8])
}
