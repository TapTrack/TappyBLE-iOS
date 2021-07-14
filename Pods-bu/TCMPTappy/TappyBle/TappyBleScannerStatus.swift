//
//  TappyBleScannerStatus.swift
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
@objc
public enum TappyBleScannerStatus : Int {
    case STATUS_CLOSED = 1
    case STATUS_SCANNING = 2
    case STATUS_POWERED_OFF = 3
    case STATUS_POWERED_ON = 4
    case STATUS_RESETTING = 5
    case STATUS_NOT_AUTHORIZED = 6
    case STATUS_NOT_SUPPORTED = 7
    case STATUS_UNKNOWN = 8
    
    func getString() -> String{
        switch self {
        case .STATUS_CLOSED:
            return "STATUS_CLOSED"
        case .STATUS_SCANNING:
            return "STATUS_SCANNING"
        case .STATUS_POWERED_OFF:
            return "STATUS_POWERED_OFF"
        case .STATUS_POWERED_ON:
            return "STATUS_POWERED_ON"
        case .STATUS_RESETTING:
            return "STATUS_RESETTING"
        case .STATUS_NOT_AUTHORIZED:
            return "STATUS_NOT_AUTHORIZED"
        case .STATUS_NOT_SUPPORTED:
            return "STATUS_NOT_SUPPORTED"
        case .STATUS_UNKNOWN:
            return "STATUS_UNKNOWN"
        }
    }
}
