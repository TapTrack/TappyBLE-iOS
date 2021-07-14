//
//  TappyBleCommunicator.swift
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
public class TappyBleCommunicator : NSObject, CBPeripheralDelegate, CBCentralManagerDelegate, TappySerialCommunicator{

    private var centralManager : CBCentralManager
    private var tappyPeripheral : CBPeripheral
    private var backingSerialService : CBService?
    private var backingRxCharacteristic : CBCharacteristic?
    private var backingTxCharacteristic : CBCharacteristic?
    
    public private(set) var state : TappyStatus = TappyStatus.STATUS_CLOSED
    private var tappyName : String
    final var bleDeviceUid : String
    @objc
    public var error : Error?
    
    
    private var dataReceivedListener : ([UInt8]) -> () = {_ in func emptyDataReceivedListener(data : [UInt8]) -> (){}}
    private var statusListener : (TappyStatus) -> () = {_ in func emptyTappyStatusListener(status : TappyStatus) -> (){}}
    private var packetsToSend: [[UInt8]] = [[UInt8]]()
    
    private init(centralManager : CBCentralManager, tappyPeripheral : CBPeripheral, tappyName : String)  {
        self.centralManager = centralManager
        self.tappyPeripheral = tappyPeripheral
        bleDeviceUid = String(describing: tappyPeripheral.identifier)
        self.tappyName = tappyName
        super.init()
        self.tappyPeripheral.delegate = self
        self.centralManager.delegate = self
    }
    @objc
    public static func getTappyBleCommunicator(centralManager : CBCentralManager, deviceId : UUID) -> TappyBleCommunicator? {
        let peripherals : [CBPeripheral] = centralManager.retrievePeripherals(withIdentifiers: [deviceId])
        if peripherals.count != 0 {
            if let deviceName = peripherals[0].name{
                if(TappyBleDeviceDefinition.isTappyDeviceName(device: peripherals[0])){
                        return TappyBleCommunicator(centralManager: centralManager,tappyPeripheral: peripherals[0],tappyName: deviceName)
                }else{
                 return nil
                }
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    
    
    // MARK: CBCentralManagerDelegate
    @objc
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central == centralManager){
            NSLog("TappyBleCommunicator: CBCM did update state")
            resolveState()
            changeStateAndNotify(newState: state)
        }else{
            NSLog("TappyBleCommunicator: Unrecognized CBCM did update state")
        }
    }
    @objc
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if(centralManager == central && tappyPeripheral == peripheral){
            if let anError = error{
                NSLog("TappyBleCommunicator: detected an error within the centralManager didConnect")
                self.error = anError
                changeStateAndNotify(newState: TappyStatus.STATUS_ERROR)
                return
            }
            NSLog("TappyBleCommunicator: CB Central Manager connected to the tappyPeripheral which is a TappyBle, attempting to discover serial service")
            tappyPeripheral.discoverServices(TappyBleDeviceDefinition.getSerialServiceUuids())
            changeStateAndNotify(newState: TappyStatus.STATUS_CONNECTING)
        }else{
            NSLog("TappyBleCommunicator: CB Central Manager connected to an unrecognized peripheral.")
        }
    }
    @objc
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if(centralManager == central && tappyPeripheral == peripheral){
             NSLog(String(format: "TappyBleCommunicator: failed to connect to peripheral %@", arguments:  [tappyName]))
            if let anError = error{
                NSLog("TappyBleCommunicator: detected an error within the centralManager didFailToConnect")
                self.error = anError
                changeStateAndNotify(newState: TappyStatus.STATUS_ERROR)
            }else{
                changeStateAndNotify(newState: TappyStatus.STATUS_DISCONNECTED)
            }
        }
    }
    @objc
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if(centralManager == central && tappyPeripheral == peripheral){
            NSLog(String(format: "TappyBleCommunicator: disconnected from peripheral %@", arguments:  [tappyName]))
            if let anError = error{
                NSLog("TappyBleCommunicator: detected an error within the centralManager didDisconnectPeripheral method")
                self.error = anError
            }
            changeStateAndNotify(newState: TappyStatus.STATUS_DISCONNECTED)
            
        }
    }
    
    //MARK : CBPeripheralDelegate
    @objc
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
           if(tappyPeripheral == peripheral){
            if let anError = error{
                NSLog("TappyBleCommunicator: detected an error within the periperal didDiscoverServices method")
                self.error = anError
                changeStateAndNotify(newState: TappyStatus.STATUS_ERROR)
                return
            }
            
            NSLog(String(format: "TappyBleCommunicator: CB Central Manager discovered a service for %@, validating service UUID..", arguments:  [tappyName]))
            if let services = peripheral.services {
                for service : CBService in services {
                    if (service.uuid.isEqual(TappyBleDeviceDefinition.getSerialServiceUuid()) || service.uuid.isEqual(TappyBleDeviceDefinition.getSerialServiceUuidV5())) {
                        NSLog(String(format: "TappyBleCommunicator: discovered service valid serial service on a %@, dicoverring Tx and Rx characteristics", arguments:  [tappyName]))
                        backingSerialService = service
                        tappyPeripheral.discoverCharacteristics([TappyBleDeviceDefinition.getRxCharacteristicUuid(),                                    TappyBleDeviceDefinition.getTxCharacteristicUuid(),TappyBleDeviceDefinition.getRxCharacteristicUuidV5(), TappyBleDeviceDefinition.getTxCharacteristicUuidV5()], for: service)
                        return
                    }
                }
                changeStateAndNotify(newState: TappyStatus.STATUS_NOT_READY_TO_CONNECT)
            }else{
                changeStateAndNotify(newState: TappyStatus.STATUS_NOT_READY_TO_CONNECT)
            }
        }
    }
    @objc
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        if(tappyPeripheral == peripheral){
             NSLog(String(format: "TappyBleCommunicator: CB Central Manager discovered characteristics for %@", arguments:  [tappyName]))
            if let anError = error{
                NSLog("TappyBleCommunicator: detected an error within the periperal didDiscoverCharacteristicsFor method")
                self.error = anError
                changeStateAndNotify(newState: TappyStatus.STATUS_ERROR)
                return
            }
            /*Todo: make these atomic perhaps? */
            var serviceCorrect : Bool = false
            var rxCharFound : Bool = false
            var txCharFound : Bool = false
            
            
            /*
             Theoretically we should not have to verify the UUIDs if the connect() method is used to attempt connection to the TappyBLE, but we will do it if TappyBleCommunicator
             is made a delegate of a CBPeriperal that has connected elsewhere, probably the application itself, without specifiing a list of desired charactersitics
             */
            
            if (service.uuid == TappyBleDeviceDefinition.getSerialServiceUuid() || service.uuid == TappyBleDeviceDefinition.getSerialServiceUuidV5()){
                backingSerialService = service
                serviceCorrect = true
                NSLog(String(format: "TappyBleCommunicator: correct serial service found for %@, validating Tx and Rx characteristics", arguments: [tappyName]))
            }else{
                NSLog(String(format: "TappyBleCommunicator: did not find the serial service for %@", arguments:  [tappyName]))
                changeStateAndNotify(newState: TappyStatus.STATUS_NOT_READY_TO_CONNECT)
                return
            }
            
            
            if let characteristics = service.characteristics {
                for characteristic : CBCharacteristic in characteristics {
                    if (characteristic.uuid == TappyBleDeviceDefinition.getRxCharacteristicUuid() || characteristic.uuid == TappyBleDeviceDefinition.getRxCharacteristicUuidV5() ){
                        backingRxCharacteristic = characteristic
                        rxCharFound = true
                        NSLog(String(format: "TappyBleCommunicator: assigned Rx Char for %@", arguments:  [tappyName]))
                    }
                    else if (characteristic.uuid == TappyBleDeviceDefinition.getTxCharacteristicUuid() || characteristic.uuid == TappyBleDeviceDefinition.getTxCharacteristicUuidV5()  ){
                        backingTxCharacteristic = characteristic
                        peripheral.setNotifyValue(true, for: characteristic) //Subscribe
                        txCharFound = true
                        NSLog(String(format: "TappyBleCommunicator: subscribed to Tx Char for %@", arguments: [tappyName]))
                    }
                }
                
                if (rxCharFound && txCharFound && serviceCorrect){
                    NSLog(String(format: "TappyBleCommunicator: %@ is ready", arguments: [tappyName]))
                    changeStateAndNotify(newState: TappyStatus.STATUS_READY)
                }else{
                    NSLog("TappyBleCommunicator: no TappyBLE Tx and Rx characteristics found")
                    changeStateAndNotify(newState: TappyStatus.STATUS_NOT_READY_TO_CONNECT)
                }
            }else{
                NSLog("TappyBleCommunicator: no characteristics found, this should not be possible since this is done inside a didDiscoverCharactersistics method")
                changeStateAndNotify(newState: TappyStatus.STATUS_NOT_READY_TO_CONNECT)
            }
        }else{
            NSLog("TappyBleCommunicator: characteristics were discovered for an unrecognized peripheral")
            changeStateAndNotify(newState: TappyStatus.STATUS_NOT_READY_TO_CONNECT)
        }
    }
    @objc
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
           if(tappyPeripheral == peripheral){
            NSLog(String(format: "TappyBleCommunicator: updated characteristic value for %@", arguments: [tappyName]))
            if let anError = error{
                NSLog("TappyBleCommunicator: detected an error within the periperal didUpdateValueFor method")
                self.error = anError
                changeStateAndNotify(newState: TappyStatus.STATUS_ERROR)
                return
            }
            charactersticRead(tappyCharacteristic : characteristic)
        }
    }
    
    private func charactersticRead(tappyCharacteristic : CBCharacteristic){
        if(tappyCharacteristic.uuid == TappyBleDeviceDefinition.getTxCharacteristicUuid() || tappyCharacteristic.uuid == TappyBleDeviceDefinition.getTxCharacteristicUuidV5() ){
            if let value = tappyCharacteristic.value{
                NSLog(String(format: "TappyBleCommunicator: Tx characteristic read for %@", arguments: [tappyName]))
                dataReceivedListener(Array(value))
            }
        }
    }
    @objc
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
           if(tappyPeripheral == peripheral){
            NSLog(String(format: "TappyBleCommunicator: didWriteValueFor for %@", arguments: [tappyName]))
            if let anError = error{
                NSLog("TappyBleCommunicator: detected an error within the periperal didWriteValueFor method")
                self.error = anError
                changeStateAndNotify(newState: TappyStatus.STATUS_ERROR)
                return
            }
            if(characteristic.uuid == TappyBleDeviceDefinition.getRxCharacteristicUuid() || characteristic.uuid == TappyBleDeviceDefinition.getRxCharacteristicUuidV5()){
                NSLog(String(format: "TappyBleCommunicator: Rx characteristic written for %@", arguments: [tappyName]))
                if packetsToSend.count > 0 {
                    packetsToSend.removeFirst()
                }
                if(packetsToSend.count != 0){
                     NSLog(String(format: "TappyBleCommunicator: more data to write to Rx characteristic for %@", arguments: [tappyName]))
                        tappyPeripheral.writeValue(Data(packetsToSend[0]), for: characteristic, type: CBCharacteristicWriteType.withResponse)
                }
            }
        }
    }
    
    
    //MARK : TappySerialCommunicator
    @objc
    public func sendBytes(data: [UInt8]) {
        let numWholePackets : UInt = UInt(data.count/20)
        let numRemainingBytes : UInt = UInt(data.count % 20)
        var numWholePacketsAppended : UInt = 0
        var numBytesAppended = 0
        
        /*Split up into 20 byte packets*/
        while numWholePacketsAppended != numWholePackets{
            var packet : [UInt8] = []
            for _ in 0..<20{
                if numBytesAppended < data.count{
                    packet.append(data[numBytesAppended])
                    numBytesAppended+=1
                }
            }
            packetsToSend.append(packet)
            numWholePacketsAppended+=1
        }
        
        if(numRemainingBytes != 0 && numRemainingBytes == data.count - numBytesAppended){
            let packet : [UInt8] = Array(data[numBytesAppended...data.count-1])
            packetsToSend.append(packet)
        }
        
            if let rxChar = backingRxCharacteristic{
                    tappyPeripheral.writeValue(Data(packetsToSend[0]), for: rxChar, type: CBCharacteristicWriteType.withResponse)
    }
    }
    @objc
    public func connect() {
        centralManager.connect(tappyPeripheral, options: nil)
        changeStateAndNotify(newState: TappyStatus.STATUS_CONNECTING)
    }
    @objc
    public func disconnect() {
                centralManager.cancelPeripheralConnection(tappyPeripheral)
    }
    @objc
    public func close() {
        disconnect()
    }
    @objc
    public func setDataListener(receivedBytes listener: @escaping ([UInt8]) -> ()) {
        dataReceivedListener = listener
    }
    @objc
    public func removeDataListener() {
        dataReceivedListener = {_ in func emptyDataReceivedListener(data : [UInt8]) -> (){}}
    }
  
    @objc public func setStatusListener(statusReceived listener: @escaping (TappyStatus) -> ()) {
        statusListener = listener
    }
   @objc
   public func removeStatusListener() {
        statusListener =  {_ in func emptyStatusListener(status : TappyStatus) -> (){}}
    }
    @objc
    public func getDeviceDescription() -> String {
        if let description = tappyPeripheral.name{
            return description
        }else{
            return ""
        }
    }
    
    
    //MARK: TappyBleCommunicator
    private func changeStateAndNotify(newState: TappyStatus){
        state = newState
        statusListener(newState)
    }
    
    private func resolveState(){
        if(centralManager.state == .poweredOff){
            NSLog("TappyBleCommunicator: BLE is powered off")
            state = TappyStatus.STATUS_NOT_READY_TO_CONNECT
        }else if(centralManager.state == .unauthorized){
            NSLog("TappyBleCommunicator: BLE is not authorized")
            state =  TappyStatus.STATUS_CLOSED
        }else if(centralManager.state == .unsupported){
            NSLog("TappyBleCommunicator: BLE is not supported")
            state =  TappyStatus.STATUS_COMMUNICATOR_ERROR
        }else if(centralManager.state == .resetting){
            NSLog("TappyBleCommunicator: BLE is resetting")
            state =  TappyStatus.STATUS_NOT_READY_TO_CONNECT
        }else if(centralManager.state == .unknown){
            NSLog("TappyBleCommunicator: BLE state is unknown")
            state =  TappyStatus.STATUS_NOT_READY_TO_CONNECT
        }else if(centralManager.state == .poweredOn){
            NSLog("TappyBleCommunicator: BLE is powered on")            
            if centralManager.retrieveConnectedPeripherals(withServices : TappyBleDeviceDefinition.getSerialServiceUuids()).count != 0 {
                state = TappyStatus.STATUS_READY
            }else{
                state = TappyStatus.STATUS_DISCONNECTED
            }
            
        }
    }
}
