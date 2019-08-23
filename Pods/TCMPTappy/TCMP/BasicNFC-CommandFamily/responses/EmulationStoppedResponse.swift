//
//  EmulationStoppedResponse.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation


@objc public class EmulationStoppedResponse: NSObject, TCMPMessage {
    
    @objc public let commandFamily: [UInt8] = CommandFamily.basicNFC
    
    @objc public let commandCode: UInt8 = BasicNFCResponseCode.emulationSuccess.rawValue
    
    @objc public private(set) var stopCode: UInt8 = 0x00
    
    @objc public private(set) var totalScansBytes: [UInt8] = [] // two bytes
    
    @objc public var totalScans: Int {
        get {
            let totalScansData = Data(totalScansBytes)
            return Int(UInt16(bigEndian: totalScansData.withUnsafeBytes { $0.pointee }))
        }
    }
    
    @objc public var payload: [UInt8] {
        get {
            return [stopCode] + totalScansBytes
        }
    }
    
    @objc public init(payload: [UInt8]) throws {
        super.init()
        try parsePayload(payload: payload)
    }
    
    @objc public func parsePayload(payload: [UInt8]) throws {
        guard payload.count >= 3 else {
            throw TCMPParsingError.payloadTooShort
        }
        stopCode = payload[0]
        totalScansBytes = Array(payload[1...2])
    }
    
}

