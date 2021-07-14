//
//  TCMPMessage.swift
//  TCMP
//
//  Created by David Shalaby on 2018-03-08.
//  Copyright © 2018 Papyrus Electronics Inc d/b/a TapTrack. All rights reserved.
//
/*
 * Copyright (c) 2018. Papyrus Electronics, Inc d/b/a TapTrack.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * you may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

public enum TCMPParsingError: Error {
    case payloadTooShort
    case resolverError(errorDescription : String)
    case invalidPollingMode
    case invalidTagTypeByte
    case notAllTagCodeBytesPresent
    case invalidPasswordProtectionMode
    case invalidAutoPollScanMode
}

@objc public protocol TCMPMessage {
    var commandFamily: [UInt8] {get}
    var commandCode: UInt8 {get}
    
    var payload: [UInt8] {get}
    func parsePayload(payload : [UInt8]) throws
}

public extension TCMPMessage{
    func toByteArray() -> [UInt8]{
        let data : [UInt8] = payload
        let family : [UInt8] = commandFamily
        let code = commandCode
        
        let length : Int = data.count + 5
        let l1 : UInt8 = UInt8(length >> 8) & UInt8(0xFF)
        let l2 : UInt8 = UInt8(length & 0xFF)
        let calcLCS1: UInt8 = UInt8(0xFF - (((l1 & 0xFF) + (l2 & 0xFF)) & 0xFF))
        let lcs : UInt8 = UInt8((calcLCS1 + (0x01 & 0xFF)) & 0xFF)
        var frame : [UInt8] = []
        var packet : [UInt8] = []
        
        frame = [l1,l2,lcs] + family + [code] + data
        packet = frame + TCMPUtils.calculateCRC(data: frame)
        return packet
    }
}
