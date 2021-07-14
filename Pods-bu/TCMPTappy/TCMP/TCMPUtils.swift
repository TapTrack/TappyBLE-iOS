//
//  TCMPUtils.swift
//  TappyBLE on iOS
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
public class TCMPUtils: NSObject {
    
    enum TCMPValidationError: Error {
        case LCSError(receivedLCS: UInt8?, calculatedLCS: UInt8?)
        case CRCError(receivedCRC: [UInt8]?, calculatedCRC: [UInt8]?)
        case lengthError(expectedLength: UInt16?, receivedLength: UInt16?)
        case frameTooShort(receivedLength: Int?)
        case rawTCMPMessageValidation
        case unknownError
    }
    
    enum HDLCError: Error{
        case noEscapeCharacterFound
        case invalidEscapeCharacterFound
        case frameTooShort
        case invalidStartOrEndOfFrame
    }
    
    @objc public class HDLCParseResult: NSObject{
        private var bytes : [UInt8]
        private let packets : [[UInt8]]
        private var remainder : [UInt8]
        
        @objc public init(bytes : [UInt8], packets : [[UInt8]], remainder : [UInt8]){
            self.bytes = bytes
            self.packets = packets
            self.remainder = remainder
        }
        
        @objc public func getBytes() ->[UInt8]{
            return bytes
        }
        
        @objc public func getPackets() -> [[UInt8]] {
            return packets
        }
        
        @objc public func getRemainder() -> [UInt8] {
            return remainder
        }
        
    }
    
    static public func HDLCByteArrayParser(bytes : [UInt8]) -> HDLCParseResult{
        if (bytes.count > 0){
            var packets : [[UInt8]] = [[]]
            var command : [UInt8] = []
            for byte in bytes{
                command.append(byte)
                if (byte == 0x7E){
                    let previousCommand : [UInt8] = command
                    if (previousCommand.count != 0) {
                        packets.append(previousCommand)
                        command = []
                        command.append(0x7E)
                    }
                }
            }
            let remainder : [UInt8] = command
            return HDLCParseResult(bytes: bytes, packets : packets, remainder : remainder )
        }else{
            return HDLCParseResult(bytes: [], packets: [[]], remainder: [])
        }
    }
    
    // cannot add @objc here: "Throwing method cannot be marked objc b/c it returns a value of type 'Bool'; 
    // return Void or a type that bridges to an Objective-C class'"
    static public func validate(data: [UInt8]) throws -> Bool {
        
            if (data.count >= 8) {

                let l1 : UInt8 = data[0]
                let l2 : UInt8 = data[1]
                let lcs : UInt8 = data[2]
                let crc: [UInt8] = [data[data.count - 2], data[data.count - 1]]

                let toCheckCRC : [UInt8] = Array(data[0...data.count-3])
                let toCheckLength : [UInt8] = Array(data[3...data.count-1])
                
                let calculatedCRC = self.calculateCRC(data: toCheckCRC)
                
                let calcLCS1: UInt8 = UInt8(0xFF - (((l1 & 0xFF) + (l2 & 0xFF)) & 0xFF))
                let calculatedLCS : UInt8 = UInt8((calcLCS1 + (0x01 & 0xFF)) & 0xFF)
                 //(((l1 & 0xFF) << 8) + (l2 & 0xFF))
                let expectedLength : UInt16 = UInt16(UInt16(UInt16(l1) * UInt16(256))+UInt16(l2))
                let toCheckLengthInt = UInt16(toCheckLength.count)
                
                if (calculatedLCS == UInt8(lcs) && calculatedCRC[0] == crc[0] && calculatedCRC[1] == crc[1]) {
                    if(expectedLength == toCheckLengthInt) {
                        NSLog(String(format: "SUCCESS-TCMP, Valid TCMP Response. Frame: %@", arguments: [data]))
                        self.logPrinting(String(format: "SUCCESS-TCMP, Valid TCMP Response. Frame: %@", arguments: [data]))
                        // self.logPrinting(String(format: "Payload: %@", arguments: [payload]))
                        return true;
                    } else {
                        NSLog(String(format: "ERROR-TCMP: Response has invalid length. Frame: %@", arguments: [data]))
                        self.logPrinting(String(format: "ERROR-TCMP Response has invalid length. Frame: %@", arguments: [data]))
                        throw TCMPValidationError.lengthError(expectedLength: expectedLength, receivedLength: toCheckLengthInt)
                    }
                } else {
                    if (calculatedLCS != UInt8(lcs)) {
                        //ERROR: Message length checksum error
                        NSLog(String(format: "ERROR-TCMP: Message length checksum error, Frame: %@", arguments: [data]))
                        self.logPrinting(String(format: "ERROR-TCMP: Message length checksum error, Frame: %@", arguments: [data]))
                        throw  TCMPValidationError.LCSError(receivedLCS: lcs, calculatedLCS: calculatedLCS)
                    } else if (expectedLength != toCheckLengthInt) {
                        NSLog(String(format: "ERROR-TCMP: Response has invalid length. Frame: %@", arguments: [data]))
                        self.logPrinting(String(format: "ERROR-TCMP: Response has invalid length. Frame: %@", arguments: [data]))
                        throw TCMPValidationError.lengthError(expectedLength: expectedLength, receivedLength: toCheckLengthInt)
                    } else if (calculatedCRC[0] != crc[0] || calculatedCRC[1] != crc[1]){ 
                        //ERROR: CRC Mismatch
                        NSLog(String(format: "ERROR-TCMP: Response has invalid CRC. Frame: %@", arguments: [data]))
                        self.logPrinting(String(format: "ERROR-TCMP: Response has invalid CRC. Frame: %@", arguments: [data]))
                        throw TCMPValidationError.CRCError(receivedCRC: crc, calculatedCRC: calculatedCRC)
                    }else{
                        //ERROR: Unknown error
                        NSLog(String(format: "ERROR-TCMP: An unknown TCMP validation error has occured. Frame: %@", arguments: [data]))
                        self.logPrinting(String(format: "ERROR-TCMP: An unknown TCMP validation error has occured. Frame: %@", arguments: [data]))
                        throw TCMPValidationError.unknownError
                    }
                }
            } else {
                //ERROR: Command too short
                NSLog(String(format: "ERROR-TCMP: Response is too short. Frame: %@", arguments: [data]))
                self.logPrinting(String(format: "ERROR-TCMP: Response is too short Frame: %@", arguments: [data]))
                throw TCMPValidationError.frameTooShort(receivedLength: data.count)
            }
    }
    
    /// <#Description#>
    ///
    /// - Parameter data: <#data description#>
    /// - Returns: <#return value description#>
    @objc static public func calculateCRC(data: [UInt8]) -> [UInt8]{
        
        var crc : UInt16 = 0x6363
        for i in 0..<data.count {
            crc = UInt16(update_crc16(crc: crc, b: data[i]))
            
        }
        return shortToByteArray(value: UInt16(crc))
        
    }
    
    @objc static private func update_crc16(crc : UInt16, b : UInt8) -> UInt16 {
        //var i: Int
        var v: UInt16 = 0x0000
        var tcrc : UInt16 = 0x0000
        v = (crc ^ UInt16(b)) & 0xff
        for _ in 0..<8 {
            tcrc = UInt16((((tcrc ^ v) & 1) != 0) ? (tcrc >> 1) ^ 0x8408 : tcrc >> 1)
            v >>= 1
        }
        return UInt16(((crc >> 8) ^ tcrc) & 0xffff)
    }
    
    @objc static private func shortToByteArray(value : UInt16) -> [UInt8] {
        
        let elem1 : UInt8 = UInt8(truncatingIfNeeded: value >> 8)
        let elem2 : UInt8 = UInt8(truncatingIfNeeded: value)
        
        let data : [UInt8] = [elem1, elem2]
        return data
    }
    
    @objc static public func containsHdlcEndpoint(packet : [UInt8]) -> Bool{
        for byte in packet {
            if (byte == 0x7E){
                return true
            }
        }
        return false
    }
    
    @objc static public func hdlcEncodePacket(packet : [UInt8]) -> [UInt8] {
        let encodedPacket : [UInt8] = hdlcEncodeData(data: packet)
        var resultingPacket : [UInt8] = []
        
        resultingPacket.append(0x7E)
        resultingPacket.append(contentsOf: encodedPacket)
        resultingPacket.append(0x7E)
        
        return resultingPacket
    }
    
    static private func hdlcEncodeData(data: [UInt8]) -> [UInt8] {
        if data.count == 0  {
            return []
        } else {
            var encodedData : [UInt8] = []
            for i in 0..<data.count {
                let byteData = data[i]
                if byteData == 0x7E {
                    encodedData.append(0x7D)
                    encodedData.append(0x5E)
                } else if byteData == 0x7D {
                    encodedData.append(0x7D)
                    encodedData.append(0x5D)
                } else {
                    encodedData.append(byteData)
                }
            }
            return encodedData
        }
    }
    
    @objc static public func hdlcDecodePacket(frame: [UInt8]) throws -> [UInt8]{
        
       if(frame.count == 0){
           return []
        }else if(frame.count > 2){
            if(frame[0] == 0x7E && frame[frame.count-1] == 0x7E){
                let deFramed = frame[1...frame.count-2]
                do{
                    return try hdlcDecodeData(packet: Array(deFramed))
                }catch HDLCError.noEscapeCharacterFound{
                    throw HDLCError.noEscapeCharacterFound
                }catch HDLCError.invalidEscapeCharacterFound{
                    throw HDLCError.invalidEscapeCharacterFound
                }
            }else{
                throw HDLCError.invalidStartOrEndOfFrame
            }
        }else{
            throw HDLCError.frameTooShort
        }
    }
    
    static private func hdlcDecodeData(packet: [UInt8]) throws -> [UInt8] {
        
        var decodedData : [UInt8] = []
        var j = 0;
        for i in 0 ..< (packet.count) {
            if i >= packet.count - j { break }
            //let dataBytes = packet.bytes.assumingMemoryBound(to: UInt8.self)
            let byteData = packet[i + j]
            if (byteData == 0x7D) {
                if (packet.count < 2) {
                    NSLog(String(format: "ERROR-HDLC: 0x7D found with no escape character found, Unescaped Frame: %@", arguments: [packet]))
                    self.logPrinting(String(format: "ERRROR-HDLC: 0x7D found with no escape character found, Unescaped Frame: %@", arguments: [packet]))
                    throw HDLCError.noEscapeCharacterFound
                }
                
                let nextByte = packet[i + j + 1]
                if (nextByte == 0x5E) {
                    decodedData.append(0x7E)
                    j += 1
                } else if (nextByte == 0x5D) {
                    decodedData.append(0x7D)
                    j += 1
                } else {
                    NSLog(String(format: "ERROR-HDLC: 0x7D found with unrecognized character, Unescaped Frame: %@", arguments: [packet]))
                    self.logPrinting(String(format: "ERROR-HDLC: 0x7D found with unrecognized character, Unescaped Frame: %@", arguments: [packet]))
                    throw HDLCError.invalidEscapeCharacterFound
                }
            } else {
                decodedData.append(byteData)
            }
        }
        
        return decodedData
    }
    

    		
    static private var logPrinting: (String)->Void = {_ in }
    
    
}
