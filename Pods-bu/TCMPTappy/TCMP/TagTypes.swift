//
//  TagTypes.swift
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

@objc public enum TagTypes : Int{
    case TAG_UNKNOWN = 0x00
    case MIFARE_ULTRALIGHT = 0x01
    case NTAG203 = 0x02
    case MIFARE_ULTRALIGHT_C = 0x03
    case MIFARE_STD_CLASSIC_1K = 0x04
    case MIFARE_STD_CLASSIC_4K = 0x05
    case MIFARE_DESFIRE_EV1_2K = 0x06
    case TYPE_2_TAG = 0x07
    case MIFARE_PLUS_2K_CL2 = 0x08
    case MIFARE_PLUS_4K_CL2 = 0x09
    case MIFARE_MINI = 0x0A
    case OTHER_TYPE4 = 0x0B
    case MIFARE_DESFIRE_EV1_4K = 0x0C
    case MIFARE_DESFIRE_EV1_8K = 0x0D
    case MIFARE_DESFIRE = 0x0E
    case TOPAZ_512 = 0x0F
    case NTAG_210 = 0x10
    case NTAG_212 = 0x11
    case NTAG_213 = 0x12
    case NTAG_215 = 0x13
    case NTAG_216 = 0x14
    case TAG_TYPE_NOT_RECOGNIZED = 0xFF
    
public init(tagCodeByteIndicator : UInt8){
        switch tagCodeByteIndicator {
        case 0x00:
            self = .TAG_UNKNOWN
        case 0x01:
            self = .MIFARE_ULTRALIGHT
        case 0x02:
            self = .NTAG203
        case 0x03:
            self = .MIFARE_ULTRALIGHT_C
        case 0x04:
            self = .MIFARE_STD_CLASSIC_1K
        case 0x05:
            self = .MIFARE_STD_CLASSIC_4K
        case 0x06:
            self = .MIFARE_DESFIRE_EV1_2K
        case 0x07:
            self = .TYPE_2_TAG
        case 0x08:
            self = .MIFARE_PLUS_2K_CL2
        case 0x09:
            self = .MIFARE_PLUS_4K_CL2
        case 0x0A:
            self = .MIFARE_MINI
        case 0x0B:
            self = .OTHER_TYPE4
        case 0x0C:
            self = .MIFARE_DESFIRE_EV1_4K
        case 0x0D:
            self = .MIFARE_DESFIRE_EV1_8K
        case 0x0E:
            self = .MIFARE_DESFIRE
        case 0x0F:
            self = .TOPAZ_512
        case 0x10:
            self = .NTAG_210
        case 0x11:
            self = .NTAG_212
        case 0x12:
            self = .NTAG_213
        case 0x13:
            self = .NTAG_215
        case 0x14:
            self = .NTAG_216
        default:
            self = .TAG_TYPE_NOT_RECOGNIZED
        }
    }

public func getTagByteIndicator()  -> UInt8{
    switch (self) {
    case TagTypes.TAG_UNKNOWN:
        return 0x00
    case TagTypes.MIFARE_ULTRALIGHT:
        return 0x01
    case TagTypes.NTAG203:
        return 0x02
    case TagTypes.MIFARE_ULTRALIGHT_C:
        return 0x03
    case TagTypes.MIFARE_STD_CLASSIC_1K:
        return 0x04
    case TagTypes.MIFARE_STD_CLASSIC_4K:
        return 0x05
    case TagTypes.MIFARE_DESFIRE_EV1_2K:
        return 0x06
    case TagTypes.TYPE_2_TAG:
        return 0x07
    case TagTypes.MIFARE_PLUS_2K_CL2:
        return 0x08
    case TagTypes.MIFARE_PLUS_4K_CL2:
        return 0x09
    case TagTypes.MIFARE_MINI:
        return 0x0A
    case TagTypes.OTHER_TYPE4:
        return 0x0B
    case TagTypes.MIFARE_DESFIRE_EV1_4K:
        return 0x0C
    case TagTypes.MIFARE_DESFIRE_EV1_8K:
        return 0x0D
    case TagTypes.MIFARE_DESFIRE:
        return 0x0E
    case TagTypes.TOPAZ_512:
        return 0x0F
    case TagTypes.NTAG_210:
        return 0x10
    case TagTypes.NTAG_212:
        return 0x11
    case TagTypes.NTAG_213:
        return 0x12
    case TagTypes.NTAG_215:
        return 0x13
    case TagTypes.NTAG_216:
        return 0x14
    case TagTypes.TAG_TYPE_NOT_RECOGNIZED:
        return 0xFF
    }
 }

    public func getString() -> String{
        switch (self) {
        case TagTypes.TAG_UNKNOWN:
            return "Tag Unknown"
        case TagTypes.MIFARE_ULTRALIGHT:
            return "Mifare Ultralight"
        case TagTypes.NTAG203:
            return  "NTAG203"
        case TagTypes.MIFARE_ULTRALIGHT_C:
            return  "Mifare Ultralight C"
        case TagTypes.MIFARE_STD_CLASSIC_1K:
            return  "Mifare Classic 1k"
        case TagTypes.MIFARE_STD_CLASSIC_4K:
            return  "Mifare Classic 4k"
        case TagTypes.MIFARE_DESFIRE_EV1_2K:
            return  "Mifare DESFire EV1 2k"
        case TagTypes.TYPE_2_TAG:
            return "NFC Forum Type 2 tag"
        case TagTypes.MIFARE_PLUS_2K_CL2:
            return "Mifare Plus 2k CL2"
        case TagTypes.MIFARE_PLUS_4K_CL2:
            return "Mifare Plus 4k CL2"
        case TagTypes.MIFARE_MINI:
            return "Mifare Mini"
        case TagTypes.OTHER_TYPE4:
            return "NFC Forum Type 4 tag"
        case TagTypes.MIFARE_DESFIRE_EV1_4K:
            return  "Mifare DESFire EV1 4k"
        case TagTypes.MIFARE_DESFIRE_EV1_8K:
            return  "Mifare DESFire EV1 8k"
        case TagTypes.MIFARE_DESFIRE:
            return "Mifare DESFire EV1, unspecified model and capacity"
        case TagTypes.TOPAZ_512:
            return "Topaz 512"
        case TagTypes.NTAG_210:
            return "NTAG210"
        case TagTypes.NTAG_212:
            return "NTAG212"
        case TagTypes.NTAG_213:
            return "NTAG213"
        case TagTypes.NTAG_215:
            return "NTAG215"
        case TagTypes.NTAG_216:
            return "NTAG216"
        case TagTypes.TAG_TYPE_NOT_RECOGNIZED:
            return "Tag Type Not Recognized"
        }
        
    }
}
