//
//  TappyBleDeviceDefinition.swift
//  TapTrackReader
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
import CoreBluetooth

@objc public class TappyBleDeviceDefinition: NSObject {
    
        @objc static public func getSerialServiceUuid() -> CBUUID{
            let SERVICE_TRUCONNECT_UUID: CBUUID = CBUUID(string: "175f8f23-a570-49bd-9627-815a6a27de2a")
            return SERVICE_TRUCONNECT_UUID
        }
    
        @objc static public func getTxCharacteristicUuid()  -> CBUUID{
            let CHARACTERISTIC_TRUCONNECT_PERIPHERAL_TX_UUID: CBUUID = CBUUID(string : "cacc07ff-ffff-4c48-8fae-a9ef71b75e26")
             return CHARACTERISTIC_TRUCONNECT_PERIPHERAL_TX_UUID
        }
    
        @objc static public func getRxCharacteristicUuid()  -> CBUUID{
            let CHARACTERISTIC_TRUCONNECT_PERIPHERAL_RX_UUID: CBUUID = CBUUID(string : "1cce1ea8-bd34-4813-a00a-c76e028fadcb")
            return CHARACTERISTIC_TRUCONNECT_PERIPHERAL_RX_UUID
        }
    
    @objc static public func isTappyDeviceName(device : CBPeripheral) -> Bool{
        if let peripheralName = device.name{
            let upperPName = peripheralName.uppercased()
            if upperPName.range(of: "TAPPY") != nil {
                    return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
}




