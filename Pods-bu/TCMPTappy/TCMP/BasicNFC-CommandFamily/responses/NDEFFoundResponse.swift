//
//  NDEFFoundResponse.swift
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


@objc public class NDEFFoundResponse : NSObject, TCMPMessage{
    
    @objc public let commandFamily: [UInt8] = CommandFamily.basicNFC
    
    @objc public let commandCode: UInt8 = BasicNFCResponseCode.ndefFound.rawValue
    
    @objc public var payload: [UInt8] {
        get {

           return [tagType.getTagByteIndicator(),UInt8(tagCode.count)] + tagCode + ndefMessage

        }
    }

    @objc public private(set) var tagType : TagTypes = TagTypes.TAG_UNKNOWN
    
    @objc public private(set) var tagCode : [UInt8] = [0x00,0x00,0x00,0x00,0x00,0x00,0x00]
    
    @objc public private(set) var ndefMessage : [UInt8] = [0xD0] // empty NDEF record header/TNF
    
    @objc public init(tagCode : [UInt8], tagType : UInt8, ndefMessage : [UInt8]){
        self.tagCode = tagCode
        self.tagType = TagTypes.init(tagCodeByteIndicator: tagType)
        self.ndefMessage = ndefMessage
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        if (payload.count < 2){
            throw TCMPParsingError.payloadTooShort
        } else if(UInt(payload[1]) > UInt(payload.count) + 2) {
            throw TCMPParsingError.notAllTagCodeBytesPresent
        } else {
            tagType = TagTypes.init(tagCodeByteIndicator: payload[0])
            let numTagCodeBytes : UInt8 = payload[1]
            let tagCodeBytes = payload[2...2+Int(numTagCodeBytes)-1]
            tagCode = Array(tagCodeBytes)
            let ndefMessageBytes = payload[2+Int(numTagCodeBytes)...payload.count-1]
            ndefMessage = Array(ndefMessageBytes)
        }
    }
    
    // Deprecated after version 0.1.12. Left here for legacy reasons.
    @objc static func getCommandCode() -> UInt8 {
        return 0x02
    }
    
}

