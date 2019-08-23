//
//  TagReadViewController.swift
//  TappyBLE
//
//  Created by David Shalaby on 2019-03-18.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import UIKit
import TCMPTappy
import NdefLibrary

class TagReadViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var rawTagDataText: UITextView!
    @IBOutlet weak var tagUIDText: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var autoPollButton: UIButton!
    
    var hasReceivedMessageAlready : Bool = false
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocalNotification.registerLocalNotifications(in: UIApplication.shared)
        TappyBLE.addBorderToTextView(textView: rawTagDataText)
        TappyBLE.addBorderToTextView(textView: tagUIDText)
        rawTagDataText.text = "Tag not read yet. No data to display."
        tagUIDText.text = "Tag not read yet. No UID to display."
    }
    
    // MARK: Actions
    
    @IBAction func autoPollPressed(_ sender: Any) {
        if let tappyBle = TappyBleManager.shared().tappyBle {
            if tappyBle.getLatestStatus() == TappyStatus.STATUS_READY {
                activityIndicator.startAnimating()
                EnableAutoPolling(listener: autoPollingResponseListener, viewControllerToToast: self,
                                  scanMode: AutoPollingScanMode.detectType2, heartbeatPeriod: 0x00, suppressBuzzer: false)
                autoPollButton.removeTarget(nil, action: nil, for: .allEvents)
                autoPollButton.addTarget(self, action: #selector(autoPollStopPressed(_:)), for: .touchUpInside)
                autoPollButton.setTitle("Stop Auto Poll", for: .normal)
            }
            else {
                self.view.makeToast("TappyBLE not connected")
            }
        }
        else {
            self.view.makeToast("TappyBLE not connected")
        }
    }
    
    @IBAction func autoPollStopPressed(_ sender: Any) {
        TappyBleManager.shared().tappyBle?.sendMessage(message: StopCommand())
        activityIndicator.stopAnimating()
        
        autoPollButton.removeTarget(nil, action: nil, for: .allEvents)
        autoPollButton.addTarget(self, action: #selector(autoPollPressed(_:)), for: .touchUpInside)
        autoPollButton.setTitle("Start Auto Poll", for: .normal)
    }
    
    @IBAction func readNFCTagPressed(_ sender: Any) {
        if let tappyBle = TappyBleManager.shared().tappyBle {
            if tappyBle.getLatestStatus() == TappyStatus.STATUS_READY {
                activityIndicator.startAnimating()
                TappyBLE.ReadNDEF(listener: tagReadResponseListener, viewControllerToToast: self, isContinuousScan: false)
            }
            else {
                self.view.makeToast("TappyBLE not connected")
            }
        }
        else {
            self.view.makeToast("TappyBLE not connected")
        }
    }
    
    @IBAction func readNFCTagUIDPressed(_ sender: Any) {
        if let tappyBle = TappyBleManager.shared().tappyBle {
            if tappyBle.getLatestStatus() == TappyStatus.STATUS_READY {
                activityIndicator.startAnimating()
                TappyBLE.ReadTag(listener: tagReadResponseListener, viewControllerToToast: self, isContinuousScan: false)
            }
            else {
                self.view.makeToast("TappyBLE not connected")
            }
        }
        else {
            self.view.makeToast("TappyBLE not connected")
        }
    }
    
    // MARK: Listeners
    
    func tagReadResponseListener(tcmpResponse : TCMPMessage) {
        NSLog("Received a valid message from Tappy")
        activityIndicator.stopAnimating()
        
        var response : TCMPMessage
        
        do {            
            response = try BasicNFCCommandResolver.resolveResponse(message: tcmpResponse)
            
            if (response is BasicNfcApplicationErrorMessage) {
                NSLog("Response is a basic NFC application error")
            } else if (response is TagWrittenResponse) {
                NSLog("Response is tag written response")
            } else if let tagReadResponse = response as? TagFoundResponse {
                NSLog("Response is tag found response")
                LocalNotification.dispatchLocalNotification(title: "Message Found", body: "Open app to see tag data", seconds: 0.5)
                
                var UIDMessage : String = String("Tag Code (UID): ")
                
                for byte in tagReadResponse.tagCode {
                    UIDMessage.append(String(format: "%02X", byte))
                    UIDMessage.append(" ")
                }
                let tagType : String = tagReadResponse.tagType.getString()
                UIDMessage.append("\r\n")
                UIDMessage.append("Tag Type: " + tagType)
                tagUIDText.text = UIDMessage
            } else if let tagReadResponse = response as? NDEFFoundResponse {
                NSLog("Response is NDEF found response")
                
                do {
                    try tagReadResponse.parsePayload(payload: tcmpResponse.payload)
                    
                    let ndefMessage = Ndef.CreateNdefMessage(rawByteArray: tagReadResponse.ndefMessage)
                    
                    var records : [NdefRecord] = [];
                    if let unwrappedMessage = ndefMessage {
                        records = unwrappedMessage.records;
                    }
                    
                    var dataMessage : String = ""
                    var UIDMessage : String = "Tag Code (UID): "
                    
                    let numRecords = records.count
                    dataMessage += "NDEF Message (\(numRecords) \(numRecords > 1 ? "Records" : "Record"))\r\n"
                    
                    for i in 0..<numRecords {
                        dataMessage += "----- Record #\(i+1) -----\r\n"
                        dataMessage += "TNF: \(String(format: "%02X", records[i].tnf))\r\n"
                        dataMessage += "Type: \"\(String(bytes: records[i].type, encoding: .utf8) ?? "Cannot display type")\"\r\n"
                        if let id = records[i].id {
                            dataMessage += "ID: \"\(String(bytes: id, encoding: .utf8) ?? "Cannot display id")\"\r\n"
                        }
                        
                        if let uriRecord = records[i] as? UriRecord {
                            let uri = uriRecord.uri;

                            NSLog("Found URL")
                            LocalNotification.dispatchLocalNotification(title: "NDEF URI Found", body: uri, seconds: 0.5)

                            dataMessage += "URI String: \(uri)\r\n"
                        } else if let textRecord = records[i] as? TextRecord {
                            let textEncoding = (textRecord.textEncoding == TextRecord.TextEncodingType.Utf8)
                                ? "UTF-8" : "UTF-16";
                            let languageCode = textRecord.languageCode;
                            let text = textRecord.text;

                            NSLog("Found Text Record")
                            LocalNotification.dispatchLocalNotification(title: "NDEF Text Found", body: text, seconds: 0.5)

                            dataMessage += "Encoding: " + textEncoding + "\r\n"
                            dataMessage += "Language: \"" + languageCode + "\"\r\n"
                            dataMessage += "Text: \"" + text + "\"\r\n"
                        } else {
                            NSLog("NFC tag did not contain URI or text")
                            LocalNotification.dispatchLocalNotification(title: "NDEF Message Found", body: "Open app to see tag data", seconds: 0.5)

                            dataMessage += "Payload: "
                            dataMessage += "\"\(String(bytes: records[i].payload, encoding: .utf8) ?? "Cannot display payload")\""
                            dataMessage += "\r\n"
                        }
                        dataMessage += "\r\n"
                    }
                    dataMessage += "\r\n"
                    
                    UIDMessage.append(bytesToHexString(tagReadResponse.tagCode))
                    
                    let tagType : String = tagReadResponse.tagType.getString()
                    UIDMessage.append("\r\n")
                    UIDMessage.append("Tag Type: " + tagType)
                    
                    NSLog(dataMessage)
                    updateDisplayText(tagData: dataMessage, uid: UIDMessage)
                }
                catch {
                    NSLog("TCMP message parsing failed")
                }
            } else {
                NSLog("Response is something the basic NFC resolver doesn't support yet")
            }
        }
        catch {
            NSLog("Message resolution failed")
        }
    }
    

    func autoPollingResponseListener(tcmpResponse : TCMPMessage) {
        var response : TCMPMessage
        
        do {
            response = try BasicNFCCommandResolver.resolveResponse(message: tcmpResponse)
            
            if let response = response as? Type2TagEntryResponse {
                var dataMessage = "----- Type 2 Tag Entered -----\r\n"
                dataMessage += "ATQA (SENS_RES): \(bytesToHexString(response.sensRes))\r\n"
                dataMessage += "SAK (SEL_RES): \(String(format:"%02X", response.selRes))\r\n\r\n"
                
                var UIDMessage : String = "Tag Code (UID): "
                UIDMessage.append(bytesToHexString(response.uid))
                
                updateDisplayText(tagData: dataMessage, uid: UIDMessage)
            } else if let response = response as? Type1TagEntryResponse {
                var dataMessage = "----- Type 1 Tag Entered -----\r\n"
                dataMessage += "ATQA (SENS_RES): \(bytesToHexString(response.sensRes))\r\n\r\n"
                
                var UIDMessage : String = "Tag Code (UID): "
                UIDMessage.append(bytesToHexString(response.uid))
                
                updateDisplayText(tagData: dataMessage, uid: UIDMessage)
            } else if let response = response as? TypeISO14443BTagEntryResponse {
                var dataMessage = "----- Type ISO 14443-4B Tag Entered -----\r\n"
                dataMessage += "ATQB: \(bytesToHexString(response.atqb))\r\n"
                dataMessage += "ATTRIB_RES: \(bytesToHexString(response.attribRes))\r\n\r\n"
                
                updateDisplayText(tagData: dataMessage, uid: "")
            } else if let response = response as? FeliCaTagEntryResponse {
                var dataMessage = "----- FeliCa Tag Entered -----\r\n"
                dataMessage += "POLL_RES_LENGTH: \(String(format:"%02X", response.pollResLength))\r\n"
                dataMessage += "RESPONSE CODE: \(String(format:"%02X", response.responseCode))\r\n"
                dataMessage += "PAD: \(bytesToHexString(response.pad))\r\n"
                dataMessage += "SYST_CODE: \(bytesToHexString(response.systCode))\r\n\r\n"
                
                var UIDMessage : String = "Tag Code (UID): "
                UIDMessage.append(bytesToHexString(response.uid))
                
                updateDisplayText(tagData: dataMessage, uid: UIDMessage)
            } else if let response = response as? Type4ATagEntryResponse     {
                var dataMessage = "----- Type 4A Tag Entered -----\r\n"
                dataMessage += "ATQA (SENS_RES): \(bytesToHexString(response.sensRes))\r\n"
                dataMessage += "SAK (SEL_RES): \(String(format:"%02X", response.selRes))\r\n"
                dataMessage += "ATS: \(bytesToHexString(response.ats))\r\n\r\n"
                
                var UIDMessage : String = "Tag Code (UID): "
                UIDMessage.append(bytesToHexString(response.uid))
                
                updateDisplayText(tagData: dataMessage, uid: UIDMessage)
            } else if let response = response as? UnrecognizedTagEntryResponse {
                var dataMessage = "----- Unrecognized Tag Entered -----\r\n"
                dataMessage += "METADATA: \(bytesToHexString(response.tagMetadata))\r\n\r\n"
                
                updateDisplayText(tagData: dataMessage, uid: "")
            } else if let response = response as? Type2TagExitResponse {
                var dataMessage = "----- Type 2 Tag Exited -----\r\n"
                dataMessage += "ATQA (SENS_RES): \(bytesToHexString(response.sensRes))\r\n"
                dataMessage += "SAK (SEL_RES): \(String(format:"%02X", response.selRes))\r\n\r\n"
                
                var UIDMessage : String = "Tag Code (UID): "
                UIDMessage.append(bytesToHexString(response.uid))
                
                updateDisplayText(tagData: dataMessage, uid: UIDMessage)
            } else if let response = response as? Type1TagExitResponse {
                var dataMessage = "----- Type 1 Tag Exited -----\r\n"
                dataMessage += "ATQA (SENS_RES): \(bytesToHexString(response.sensRes))\r\n\r\n"
                
                var UIDMessage : String = "Tag Code (UID): "
                UIDMessage.append(bytesToHexString(response.uid))
                
                updateDisplayText(tagData: dataMessage, uid: UIDMessage)
            } else if let response = response as? TypeISO14443BTagExitResponse {
                var dataMessage = "----- Type ISO 14443-4B Tag Exited -----\r\n"
                dataMessage += "ATQB: \(bytesToHexString(response.atqb))\r\n"
                dataMessage += "ATTRIB_RES: \(bytesToHexString(response.attribRes))\r\n\r\n"
                
                updateDisplayText(tagData: dataMessage, uid: "")
            } else if let response = response as? FeliCaTagExitResponse {
                var dataMessage = "----- FeliCa Tag Exited -----\r\n"
                dataMessage += "POLL_RES_LENGTH: \(String(format:"%02X", response.pollResLength))\r\n"
                dataMessage += "RESPONSE CODE: \(String(format:"%02X", response.responseCode))\r\n"
                dataMessage += "PAD: \(bytesToHexString(response.pad))\r\n"
                dataMessage += "SYST_CODE: \(bytesToHexString(response.systCode))\r\n\r\n"
                
                var UIDMessage : String = "Tag Code (UID): "
                UIDMessage.append(bytesToHexString(response.uid))
                
                updateDisplayText(tagData: dataMessage, uid: UIDMessage)
            } else if let response = response as? Type4ATagExitResponse     {
                var dataMessage = "----- Type 4A Tag Exited -----\r\n"
                dataMessage += "ATQA (SENS_RES): \(bytesToHexString(response.sensRes))\r\n"
                dataMessage += "SAK (SEL_RES): \(String(format:"%02X", response.selRes))\r\n"
                dataMessage += "ATS: \(bytesToHexString(response.ats))\r\n\r\n"
                
                var UIDMessage : String = "Tag Code (UID): "
                UIDMessage.append(bytesToHexString(response.uid))
                
                updateDisplayText(tagData: dataMessage, uid: UIDMessage)
            } else if let response = response as? UnrecognizedTagExitResponse {
                var dataMessage = "----- Unrecognized Tag Exited -----\r\n"
                dataMessage += "METADATA: \(bytesToHexString(response.tagMetadata))\r\n\r\n"
                
                updateDisplayText(tagData: dataMessage, uid: "")
            } else {
                NSLog("Auto Polling Listener: Response with command family \(response.commandFamily) and command code \(response.commandCode) not supported.")
            }
        } catch {
            NSLog("Auto polling response resolution failed: \(error)")
        }
    }
    
    // MARK: - Utility
    
    func updateDisplayText(tagData: String, uid: String) {
        if hasReceivedMessageAlready {
            rawTagDataText.text.append(tagData)
        } else {
            rawTagDataText.textAlignment = .left
            rawTagDataText.text = tagData
            hasReceivedMessageAlready = true
        }
        tagUIDText.text = uid
        
        rawTagDataText.scrollToBottom()
    }
    
    // MARK: Dev
    
    //    func devPopulateDisplays() {
    //        let tagCode = "04 C6 59 A2 A9 4A 90"
    //        var UIDMessage = String("Tag Code (UID): ")
    //        var dataMessage = "NDEF MESSAGE FOUND:\r\n"
    //        dataMessage.append("TNF: 01\r\n")
    //        dataMessage.append("Type: T\r\n")
    //        dataMessage.append("Payload: enThis is an example text payload.\r\n")
    //        dataMessage.append("Tag Code (UID):\r\n")
    //        dataMessage.append(tagCode)
    //
    //        UIDMessage.append(tagCode + "\r\n")
    //        UIDMessage.append("Tag Type: NFC Forum Type 2 Tag")
    //
    //        rawTagDataText.textAlignment = .left
    //        rawTagDataText.text = dataMessage
    //        tagUIDText.text = UIDMessage
    //        NSLog(dataMessage)
    //    }
}
