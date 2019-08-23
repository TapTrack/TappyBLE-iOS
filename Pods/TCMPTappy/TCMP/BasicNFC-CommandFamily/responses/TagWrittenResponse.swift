//
//  TagWrittenResponse.swift
//  TappySDKExampleWithSDKSource
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

@objc public class TagWrittenResponse : NSObject, TCMPMessage{
    
    @objc public let commandFamily: [UInt8] = CommandFamily.basicNFC
    
    @objc public let commandCode: UInt8 = BasicNFCResponseCode.tagWritten.rawValue
    
    @objc public var payload: [UInt8] {
        get{
            return [tagType.getTagByteIndicator()] + tagCode
        }
    }

    @objc public private(set) var tagType : TagTypes = TagTypes.TAG_UNKNOWN
    @objc public private(set) var tagCode : [UInt8] = [0x00,0x00,0x00,0x00,0x00,0x00,0x00]
    
    @objc public init(tagCode : [UInt8], tagType: TagTypes){
        self.tagCode = tagCode
        self.tagType = tagType
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }

    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count > 1 else {
            throw TCMPParsingError.payloadTooShort
        }
        
        tagType = TagTypes(tagCodeByteIndicator: payload[0])
        tagCode = Array(payload[1...payload.count-1])
    }

    // Deprecated after version 0.1.12. Left here for legacy reasons.
    @objc public static func getCommandCode() -> UInt8 {
        return 0x05
    }

}

