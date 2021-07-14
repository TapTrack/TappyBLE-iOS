//
//  Util.swift
//  TappyBLE
//
//  Created by Alice Cai on 2019-08-14.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation

// MARK: - URI util functions

public let uriPrefixProtocols: [String] =
    ["",
     "http://www.",
     "https://www.",
     "http://",
     "https://",
     "tel:",
     "mailto:",
     "ftp://anonymous:anonymous@",
     "ftp://ftp.",
     "ftps://",
     "sftp://",
     "smb://",
     "nfs://",
     "ftp://",
     "dav://",
     "news:",
     "telnet://",
     "imap:",
     "rtsp://",
     "urn:",
     "pop:",
     "sip:",
     "sips:",
     "tftp:",
     "btspp://",
     "btl2cap://",
     "btgoep://",
     "tcpobex://",
     "irdaobex://",
     "file://",
     "urn:epc:id:",
     "urn:epc:tag:",
     "urn:epc:pat:",
     "urn:epc:raw:",
     "urn:epc:",
     "urn:nfc:"]

// returns a tuple containing the protocol code and the protocol length
public func getProtocolCodeFromUri(_ uri: String) -> (UInt8, Int) {
    for i in 1 ..< uriPrefixProtocols.count {
        if uri.starts(with: uriPrefixProtocols[i]) {
            return (UInt8(i), uriPrefixProtocols[i].count)
        }
    }
    return (0x00, 0)
}

public func getUriProtocolFromCode(_ identifierCode: UInt8) -> String {
    if identifierCode >= 0 && identifierCode < uriPrefixProtocols.count {
        return uriPrefixProtocols[Int(identifierCode)]
    }
    return ""
}


// MARK: - Other util functions

public func bytesToHexString(_ bytes: [UInt8]) -> String {
    var hexString : String = ""
    for byte in bytes {
        hexString.append(String(format: "%02X", byte))
        hexString.append(" ")
    }
    return hexString
}
