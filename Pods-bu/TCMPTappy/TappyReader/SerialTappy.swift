//
//  SerialTappy.swift
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
public class SerialTappy : NSObject, Tappy {
    
    var communicator : TappySerialCommunicator
    @objc var receiveBuffer : [UInt8] = []
    var statusListener : (TappyStatus) -> () = {_ in func emptyStatusListener(status: TappyStatus) -> (){}}
    @objc var responseListener : (TCMPMessage) -> () = {_ in func emptyResponseListener(message: TCMPMessage) -> (){}}
    @objc var responseListenerJSON : (TCMPMessage, String) -> () = {_,_ in func emptyResponseListener(message: TCMPMessage, data: String) -> (){}}
    @objc var unparsableListener : ([UInt8]) -> () = {_ in func emptyUnparsablePacketListener(packet : [UInt8]) -> (){}}
    
    
    public init(communicator : TappySerialCommunicator){
        responseListener = {_ in func emptyResponseListener(message: TCMPMessage) -> (){}}
        responseListenerJSON = {_,_ in func emptyResponseListener(message: TCMPMessage, data: String) -> (){}}
        statusListener = {_ in func emptyStatusListener(status: TappyStatus) -> (){}}
        unparsableListener = {_ in func emptyUnparsablePacketListener(packet : [UInt8]) -> (){}}
        self.communicator = communicator
        super.init()
        communicator.setDataListener(receivedBytes: receiveBytes)
        communicator.setStatusListener(statusReceived: notifyListenerOfStatus)
    }
    
    @objc public func receiveBytes(data : [UInt8]){
        var commands : [[UInt8]] = [[]]
        receiveBuffer.append(contentsOf: data)
        if(TCMPUtils.containsHdlcEndpoint(packet: data)){
            let currentBuffer : [UInt8] = receiveBuffer
            let parseResult : TCMPUtils.HDLCParseResult = TCMPUtils.HDLCByteArrayParser(bytes: currentBuffer)
            commands = parseResult.getPackets()
            receiveBuffer = parseResult.getRemainder()
        }
        
        if (commands.count == 0){
            return
        }
        
        for hdlcPacket in commands{
            do{
                let decodedPacket : [UInt8] = try TCMPUtils.hdlcDecodePacket(frame: hdlcPacket)
                if(decodedPacket.count != 0){
                    do{
                        let message : RawTCMPMesssage = try RawTCMPMesssage(message: decodedPacket)
                        responseListener(message)
                        let jsonObject : [String: Any] = [
                            "payload": message.payload,
                            "commandCode": message.commandCode,
                            "commandFamily": message.commandFamily
                        ]
                        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
                        let jsonString = String(data: jsonData, encoding: String.Encoding.ascii)!
                        responseListenerJSON(message, jsonString)
                    }catch{
                        unparsableListener(hdlcPacket)
                    }
                }else{
                    unparsableListener(hdlcPacket)
                }
            }catch{
                unparsableListener(hdlcPacket)
            }
        }
    }
    
    @objc public func setResponseListener(listener: @escaping (TCMPMessage) -> ()) {
        responseListener = listener
    }
    
    @objc public func setResponseListenerJSON(listener: @escaping (TCMPMessage, String) -> ()) {
        responseListenerJSON = listener
    }
    
    @objc public func removeResponseListener() {
        responseListener = {_ in func emptyResponseListener(message: TCMPMessage) -> (){}}
        responseListenerJSON = {_,_ in func emptyResponseListener(message: TCMPMessage, data: String) -> (){}}
    }
    
    @objc public func setStatusListener(listener: @escaping (TappyStatus) -> ()) {
        statusListener = listener
    }
    
    @objc public func removeStatusListener() {
        statusListener = {_ in func emptyStatusListener(status: TappyStatus) -> (){}}
    }
    
    @objc public func setUnparsablePacketListener(listener: @escaping ([UInt8]) -> ()) {
        unparsableListener = listener
    }
    
    @objc public func removeUnparsablePacketListener() {
        unparsableListener = {_ in func emptyUnparsablePacketListener(packet : [UInt8]) -> (){}}
    }
    
    @objc public func removeAllListeners() {
        removeResponseListener()
        removeUnparsablePacketListener()
        removeUnparsablePacketListener()
    }
    
    private func notifyListenerOfStatus(status : TappyStatus){
        statusListener(status)
    }
    
    @objc public func connect(){
        communicator.connect()
        
    }
    
    @objc public func sendMessage(message: TCMPMessage) {
        communicator.sendBytes(data: TCMPUtils.hdlcEncodePacket(packet: message.toByteArray()))
    }
    
    @objc public func disconnect() {
        communicator.disconnect()
    }
    
    @objc public func close() {
        communicator.close()
    }
    
    @objc public func getDeviceDescription() -> String {
        return communicator.getDeviceDescription();
    }
    
    @objc public func getLatestStatus() -> TappyStatus {
        return communicator.state
    }
    
    @objc public func getCommunicator() -> TappySerialCommunicator{
        return communicator
    }
    
}


