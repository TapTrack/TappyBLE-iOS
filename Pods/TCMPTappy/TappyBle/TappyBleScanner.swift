//
//  TappyBleScanner.swift
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
import CoreBluetooth
@objc
public class TappyBleScanner : NSObject, CBCentralManagerDelegate{
    
    private var centralManager : CBCentralManager
    private var tappyFoundListener : (TappyBleDevice) -> () = {_ in func emptyTappyFoundListener(tappy: TappyBleDevice) -> (){}}
    private var tappyFoundListenerJSON : (TappyBleDevice, String) -> () = {_,_  in func emptyTappyFoundListenerJSON(tappy: TappyBleDevice, name: String) -> (){}}
    @objc public var statusListener : (TappyBleScannerStatus) -> () = {_ in func emptyStatusListener(status: TappyBleScannerStatus) -> (){}}
    private var state : TappyBleScannerStatus = TappyBleScannerStatus.STATUS_CLOSED
    
    @objc
    public init(centralManager : CBCentralManager){
        self.centralManager = centralManager
        super.init()
        centralManager.delegate = self
    }
    @objc
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        resolveState()
        changeStateAndNotify(newState: state)
    }
    @objc
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(central == centralManager){
            NSLog("TappyBleScanner: Discovered a peripheral, validating name... ")
            if(TappyBleDeviceDefinition.isTappyDeviceName(device: peripheral)){
                NSLog(String(format: "TappyBleScanner: peripheral %@ has a valid name, passing to tappyFoundListener", arguments: [peripheral.name!]))
                let tappy: TappyBleDevice = TappyBleDevice(name: peripheral.name!, deviceId: peripheral.identifier)
                tappyFoundListener(tappy)
                let tappyJSONObj : [String: Any] = [
                    "deviceName": tappy.name(),
                    "deviceId": tappy.deviceId.description
                ]
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: tappyJSONObj, options: [])
                    let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
                    tappyFoundListenerJSON(tappy, jsonString)
                } catch {
                    NSLog("Error creating JSON object")
                }
            }else{
                NSLog("TappyBleScanner: peripheral has invalid name, not a TappyBLE")
            }
        }else{
            NSLog("TappyBleScanner: Unknown CBCM Discovered a peripheral")
        }
    }
    
    @objc public func startScan() -> Bool{
        if state == TappyBleScannerStatus.STATUS_POWERED_ON{
            centralManager.scanForPeripherals(withServices: TappyBleDeviceDefinition.getSerialServiceUuids(), options: nil)
            changeStateAndNotify(newState: TappyBleScannerStatus.STATUS_SCANNING)
            return true
        }
        return false
    }
    
    @objc public func stopScan(){
        centralManager.stopScan()
        resolveState()
        changeStateAndNotify(newState: state)
    }
    
    @objc public func getState() -> TappyBleScannerStatus{
        resolveState()
        return state
    }
    
    private func changeStateAndNotify(newState: TappyBleScannerStatus){
        state = newState
       statusListener(newState)
    }
    
    @objc public func setTappyFoundListener(listener : @escaping (TappyBleDevice) -> ()){
        tappyFoundListener = listener
    }
    
    @objc public func setTappyFoundListenerJSON(listener : @escaping (TappyBleDevice, String) -> ()){
        tappyFoundListenerJSON = listener
    }

    
    @objc public func removeTappyFoundListener(){
        tappyFoundListener = {_ in func emptyTappyFoundListener(tappy: TappyBleDevice) -> (){}}
        tappyFoundListenerJSON = {_,_  in func emptyTappyFoundListenerJSON(tappy: TappyBleDevice, name: String) -> (){}}
    }

    @objc public func setStatusListener(statusReceived listener: @escaping (TappyBleScannerStatus) -> ()) {
        statusListener = listener
    }
    
    @objc public func removeStatusListener() {
        statusListener =  {_ in func emptyStatusListener(status: TappyBleScannerStatus) -> (){}}
    }
    
    
    private func resolveState(){
        if(centralManager.state == .poweredOff){
            NSLog("TappyBleScanner: BLE is powered off")
            state = TappyBleScannerStatus.STATUS_POWERED_OFF
        }else if(centralManager.state == .unauthorized){
            NSLog("TappyBleScanner: BLE is not authorized")
            state =  TappyBleScannerStatus.STATUS_NOT_AUTHORIZED
        }else if(centralManager.state == .unsupported){
            NSLog("TappyBleScanner: BLE is not supported")
            state =  TappyBleScannerStatus.STATUS_NOT_SUPPORTED
        }else if(centralManager.state == .resetting){
            NSLog("TappyBleScanner: BLE is resetting")
            state =  TappyBleScannerStatus.STATUS_RESETTING
        }else if(centralManager.state == .unknown){
            NSLog("TappyBleScanner: BLE state is unknown")
            state =  TappyBleScannerStatus.STATUS_UNKNOWN
        }else if(centralManager.state == .poweredOn){
            NSLog("TappyBleScanner: BLE is powered on")
            if #available(iOS 9.0, *) {
                if(centralManager.isScanning){
                    state =  TappyBleScannerStatus.STATUS_SCANNING
                }else{
                    state =  TappyBleScannerStatus.STATUS_POWERED_ON
                }
            } else {
                state =  TappyBleScannerStatus.STATUS_POWERED_ON
            }
        }
    }
}
