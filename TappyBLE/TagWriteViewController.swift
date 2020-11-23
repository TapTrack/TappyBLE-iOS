//
//  TagWriteViewController.swift
//  TappyBLE
//
//  Created by Ga-Chun Lin on 2019-03-18.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import UIKit
import TCMPTappy

class TagWriteViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var writeTextToTagButton: UIButton!
    @IBOutlet weak var writeUriToTagButton: UIButton!
    @IBOutlet weak var textInputField: UITextField!
    @IBOutlet weak var uriInputField: UITextField!
    
    @IBOutlet weak var writeCustomNdefToTagButton: UIButton!
    @IBOutlet weak var customNdefInputField: UITextField!
    @IBOutlet weak var customNdefSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var hasEditedText : Bool = false
    var hasEditedUri : Bool = false
    var hasEditedCustomNdef : Bool = false
    var isAwaitingTap : Bool = false
    
    let hexChars = NSCharacterSet(charactersIn: "0123456789ABCDEF")
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        writeTextToTagButton.isEnabled = false
        writeUriToTagButton.isEnabled = false
        textInputField.delegate = self
        uriInputField.delegate = self
        
        textInputField.textColor = .lightGray
        uriInputField.textColor = .lightGray
        customNdefInputField.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.hideKeyboardOnOutsideTap()
    }
    
    // MARK: Actions
    
    @IBAction func writeTextButtonPressed(_ sender: Any) {
        if let tappyBle = TappyBleManager.shared().tappyBle {
            if tappyBle.getLatestStatus() == TappyStatus.STATUS_READY && !isAwaitingTap {
                isAwaitingTap = true
                activityIndicator.startAnimating()
                TappyBLE.WriteTextToNDEF(listener: defaultResponseListener, viewControllerToToast: self, text: textInputField.text ?? "")
            }
            else {
                self.view.makeToast("TappyBLE not connected")
            }
        }
        else {
            self.view.makeToast("TappyBLE not connected")
        }
    }
    
    @IBAction func writeUriButtonPressed(_ sender: Any) {
        if let tappyBle = TappyBleManager.shared().tappyBle {
            if tappyBle.getLatestStatus() == TappyStatus.STATUS_READY && !isAwaitingTap {
                isAwaitingTap = true
                activityIndicator.startAnimating()
                TappyBLE.WriteUriToNDEF(listener: defaultResponseListener, viewControllerToToast: self, uri: uriInputField.text ?? "")
            }
            else {
                self.view.makeToast("TappyBLE not connected")
            }
        }
        else {
            self.view.makeToast("TappyBLE not connected")
        }
    }
    
    @IBAction func writeCustomNdefButtonPressed(_ sender: Any) {
        if customNdefSegmentedControl.selectedSegmentIndex == 0 {
            if let tappyBle = TappyBleManager.shared().tappyBle {
                if tappyBle.getLatestStatus() == TappyStatus.STATUS_READY {
                    activityIndicator.startAnimating()
                    TappyBLE.ReadNDEF(listener: defaultResponseListener, viewControllerToToast: self, isContinuousScan: false)
                }
                else {
                    self.view.makeToast("TappyBLE not connected")
                }
            }
            else {
                self.view.makeToast("TappyBLE not connected")
            }
        }
        if customNdefSegmentedControl.selectedSegmentIndex == 1 {
            if let tappyBle = TappyBleManager.shared().tappyBle {
                if tappyBle.getLatestStatus() == TappyStatus.STATUS_READY && !isAwaitingTap {
                    isAwaitingTap = true
                    activityIndicator.startAnimating()
                    TappyBLE.WriteRawNDEF(listener: defaultResponseListener, viewControllerToToast: self, hexString: customNdefInputField.text ?? "")
                }
                else {
                    self.view.makeToast("TappyBLE not connected")
                }
            }
            else {
                self.view.makeToast("TappyBLE not connected")
            }
        }
    }
    
    @IBAction private func textInputDidBeginEditing(_ sender: Any) {
        if !hasEditedText {
            textInputField.text = ""
            hasEditedText = true
            textInputField.textColor = .black
        }
    }
    
    @IBAction func uriInputDidBeginEditing(_ sender: Any) {
        if !hasEditedUri {
            hasEditedUri = true
            uriInputField.textColor = .black
            moveCursorToEndOfText(textField: uriInputField)
        }
    }
    
    @IBAction func customInputDidBeginEditing(_ sender: Any) {
        
    }
    
    @IBAction func textInputDidChange(_ sender: Any) {
        let text = textInputField.text!
        if !text.isEmpty {
            writeTextToTagButton.isEnabled = true
        }
        else {
            writeTextToTagButton.isEnabled = false
        }
    }
    
    @IBAction func uriInputDidChange(_ sender: Any) {
        let text = uriInputField.text!
        if !(text.isEmpty && text == "https://") {
            writeUriToTagButton.isEnabled = true
        }
        else {
            writeUriToTagButton.isEnabled = false
        }
    }
    
    @IBAction func customInputDidChange(_ sender: Any) {
        let text = customNdefInputField.text!
        customNdefInputField.text = text.uppercased()
        let isValidNexNumber = !(text.rangeOfCharacter(from: hexChars.inverted) != nil)
        if (isValidNexNumber) {
            writeCustomNdefToTagButton.isEnabled = true
        }
        else {
            writeCustomNdefToTagButton.isEnabled = false
        }
    }
    
    @IBAction func customNdefTypeControlDidChange(_ sender: Any) {
        if customNdefSegmentedControl.selectedSegmentIndex == 0 {
            customNdefInputField.isEnabled = false
        }
        if customNdefSegmentedControl.selectedSegmentIndex == 1 {
            customNdefInputField.isEnabled = true
        }
    }
    
    @IBAction private func textInputDidEndEditing(_ sender: Any) {
        let text = textInputField.text!
        if text.isEmpty {
            textInputField.text = "Enter text..."
            textInputField.textColor = .lightGray
            hasEditedText = false
        }
    }
    
    @IBAction func uriInputDidEndEditing(_ sender: Any) {
        let text = uriInputField.text!
        if text.isEmpty || text == "https://" {
            uriInputField.textColor = .lightGray
            hasEditedUri = false
            if text.isEmpty {
                uriInputField.text = "https://"
            }
        }
    }
    
    @IBAction func customInputDidEndEditing(_ sender: Any) {
    }
    
    // MARK: Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        //  Calculate exact keyboard size
        self.scrollView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        // On keyboard disappear, restore original position
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    // MARK: Listeners

    func defaultResponseListener(tcmpResponse : TCMPMessage) {
        NSLog("Received a valid message from Tappy")
        activityIndicator.stopAnimating()
        isAwaitingTap = false
        
        //let resolver : BasicNFCCommandResolver = BasicNFCCommandResolver()
        var response : TCMPMessage
        
        do {
            try response = BasicNFCCommandResolver.resolveResponse(message: tcmpResponse)
            if (response is BasicNfcApplicationErrorMessage) {
                NSLog("Response is a basic NFC application error")
            }
            else if (response is TagWrittenResponse) {
                NSLog("Response is tag written response")
                
                var tagWrittenResponse: TagWrittenResponse
                do {
                    tagWrittenResponse = try TagWrittenResponse(payload: tcmpResponse.payload)
                    var tagWrittenToastMessage : String
                    let tagType : String = tagWrittenResponse.tagType.getString()
                    var tagCode : String = ""
                    for byte in tagWrittenResponse.tagCode {
                        tagCode.append(contentsOf: String(format: "%02X", byte))
                        tagCode.append(" ")
                    }
                    tagWrittenToastMessage = "Data written to tag.\nTag Type: " + tagType + "\nTag Code: " + tagCode
                    self.view.makeToast(tagWrittenToastMessage)
                }
                catch {
                    NSLog("TCMP message parsing failed")
                }
            }
            else if (response is NDEFFoundResponse) {
                NSLog("Response is NDEF found response")
                var tagReadResponse : NDEFFoundResponse
                tagReadResponse = (response as! NDEFFoundResponse)
                do {
                    try tagReadResponse = NDEFFoundResponse(payload: tcmpResponse.payload)
                    let lastReadNdef = tagReadResponse.ndefMessage
                    if let tappyBle = TappyBleManager.shared().tappyBle {
                        self.view.makeToast("Please wait 2 seconds", duration: 2.0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                            if tappyBle.getLatestStatus() == TappyStatus.STATUS_READY && !self.isAwaitingTap {
                                self.isAwaitingTap = true
                                TappyBLE.WriteCustomNDEF(listener: self.defaultResponseListener, viewControllerToToast: self, rawNdef: lastReadNdef)
                            }
                            else {
                                self.view.makeToast("TappyBLE not connected")
                            }
                        })
                    }
                    else {
                        self.view.makeToast("TappyBLE not connected")
                    }
                }
                catch {
                    NSLog("TCMP message parsing failed")
                }
            }
            else {
                NSLog("Response is something the basic NFC resolver doesn't support yet")
            }
        }
        catch {
            NSLog("Message resolution failed")
        }
    }
    
    // MARK: Dev
    
//    func devPopulateDisplays() {
//        let tagType = "NFC Forum Type 2 Tag"
//        let tagCode = "04 C6 59 A2 A9 4A 90"
//        let tagWrittenToastMessage = "Data written to tag.\nTag Type: " + tagType + "\nTag Code: " + tagCode
//        self.view.makeToast(tagWrittenToastMessage)
//    }
}

// MARK: Helpers

func moveCursorToEndOfText(textField: UITextField) {
    let endPosition = textField.endOfDocument
    textField.selectedTextRange = textField.textRange(from: endPosition, to: endPosition)
}
