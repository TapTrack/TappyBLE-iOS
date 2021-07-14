//
//  Tappy.swift
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

protocol Tappy {
    func connect()
    func sendMessage(message : TCMPMessage)
    func disconnect()
    func close()
    func getDeviceDescription() -> String
    func getLatestStatus() -> TappyStatus
    
    func setResponseListener(listener : @escaping (TCMPMessage) -> ())
    func removeResponseListener()
    
    func setStatusListener(listener : @escaping (TappyStatus) -> ())
    func removeStatusListener()
    
    func setUnparsablePacketListener(listener : @escaping ([UInt8]) -> ())
    func removeUnparsablePacketListener()
    
    func removeAllListeners()
}
