//
//  TappyStatus.swift
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

@objc public enum TappyStatus : Int {
    case STATUS_DISCONNECTED = 1
    case STATUS_CONNECTING = 2
    case STATUS_READY = 3
    case STATUS_DISCONNECTING = 4
    case STATUS_CLOSED = 5
    case STATUS_ERROR = 6
    case STATUS_NOT_READY_TO_CONNECT = 7
    case STATUS_COMMUNICATOR_ERROR = 8
    
    public func getString() -> String{
        switch self {
        case .STATUS_DISCONNECTED:
            return "STATUS_DISCONNECTED"
        case .STATUS_CONNECTING:
            return "STATUS_CONNECTING"
        case .STATUS_READY:
            return "STATUS_READY"
        case .STATUS_DISCONNECTING:
            return "STATUS_DISCONNECTING"
        case .STATUS_CLOSED:
            return "STATUS_CLOSED"
        case .STATUS_ERROR:
            return "STATUS_ERROR"
        case .STATUS_NOT_READY_TO_CONNECT:
            return "STATUS_NOT_READY_TO_CONNECT"
        case .STATUS_COMMUNICATOR_ERROR:
            return "STATUS_COMMUNICATOR_ERROR"
        }
    }
}

