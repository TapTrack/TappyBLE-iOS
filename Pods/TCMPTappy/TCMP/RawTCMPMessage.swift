//
//  RawTCMPMessage.swift
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
@objc
public class RawTCMPMesssage : NSObject, TCMPMessage
{
    
    @objc public private(set) var commandCode: UInt8
    @objc public private(set) var payload: [UInt8]
    @objc public private(set) var commandFamily: [UInt8]
    
    @objc public init(commandCode: UInt8, commandFamily: [UInt8], payload: [UInt8] ){
        self.commandCode = commandCode;
        self.commandFamily = commandFamily
        self.payload = payload	
    }
    
    @objc public init(message: [UInt8]) throws {
        do{
            if(try TCMPUtils.validate(data: message)){
                commandFamily = [message[3], message[4]]
                commandCode = message[5]
                if message.count > 8 {
                    let messageSlice = message[6...Int(message.count-3)]
                    payload = Array(messageSlice)
                }else{
                    payload = []
                }
            }else{
                throw TCMPUtils.TCMPValidationError.rawTCMPMessageValidation
            }
        }catch {
            throw TCMPUtils.TCMPValidationError.rawTCMPMessageValidation
        }
    }
    
    @objc public func parsePayload(payload : [UInt8]) throws {
        self.payload = payload
    }
}

