//
//  CommandFamilyConstants.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-12.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

public enum CommandFamily {
    static let system: [UInt8] = [0x00, 0x00]
    static let basicNFC: [UInt8] = [0x00, 0x01]
    static let type4: [UInt8] = [0x00, 0x04]
    static let ntag21x: [UInt8] = [0x00, 0x06]
}
