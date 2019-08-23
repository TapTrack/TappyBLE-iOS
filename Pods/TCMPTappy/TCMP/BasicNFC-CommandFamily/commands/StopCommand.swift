//
//  StopCommand.swift
//  TapTrackReader (TCMP)
//
//  Created by Frank Hackenburg on 2018-04-09.
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

@objc public class StopCommand : NSObject, TCMPMessage {
    
    @objc public let commandFamily : [UInt8] = CommandFamily.basicNFC
    
    @objc public let commandCode : UInt8 = BasicNFCCommandCode.stop.rawValue
    
    @objc public var payload: [UInt8] {
        get {
            return []
        }
    }
    
    @objc public override init() {}
    
    @objc public func parsePayload(payload: [UInt8]) throws {}
    
    // Deprecated after version 0.1.12. Left here for legacy reasons.
    @objc public static func getCommandCode() -> UInt8 {
        return 0x00
    }
}
