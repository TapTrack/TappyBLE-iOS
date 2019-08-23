//
//  Utils.swift
//  TappyBLE
//
//  Created by David Shalaby on 2019-03-18.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import UIKit
import TCMPTappy
import Toast_Swift
import UserNotifications

// MARK: - Extensions

extension UIViewController {
    func hideKeyboardOnOutsideTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIScrollView {
    func scrollToBottom() {
        let contentHeight = contentSize.height - frame.size.height
        let contentoffsetY = contentHeight > 0 ? contentHeight : 0
        setContentOffset(CGPoint(x: 0, y: contentoffsetY), animated: true)
    }
}

extension UITableView {
    func deselectSelectedRow(animated: Bool) {
        if let indexPathForSelectedRow = self.indexPathForSelectedRow {
            self.deselectRow(at: indexPathForSelectedRow, animated: animated)
        }
    }
}

extension StringProtocol {
    var hexToBytes: [UInt8] {
        let hex = Array(self)
        return stride(from: 0, to: count, by: 2).compactMap { UInt8(String(hex[$0...$0.advanced(by: 1)]), radix: 16) }
    }
}

extension Data {
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

extension Date {
    func addedBy(seconds:Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }
}

// MARK: - Helpers

func addBorderToTextView(textView: UITextView) {
    let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    textView.layer.borderWidth = 0.5
    textView.layer.cornerRadius = 5.0
    textView.layer.borderColor = borderColor.cgColor
}

func addBorderToTableView(tableView: UITableView) {
    let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
    tableView.layer.borderWidth = 0.5
    tableView.layer.cornerRadius = 5.0
    tableView.layer.borderColor = borderColor.cgColor
}

func ShowTappyNotConnectedAlert(viewController: UIViewController) {
    let alertController = UIAlertController(title: "TappyBLE", message: "TappyBLE not connected", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
    viewController.present(alertController, animated: true, completion: nil)
}


// MARK: Basic NFC commands

func ReadNDEF(listener: @escaping (TCMPMessage) -> (), viewControllerToToast: UIViewController?, isContinuousScan: Bool = false) {
    if TappyBleManager.shared().tappyBle?.getLatestStatus() == TappyStatus.STATUS_READY {
        let commandToSend : TCMPMessage
        if isContinuousScan {
            commandToSend = StreamNDEFCommand(timeout: 0, pollingMode: PollingMode.pollForGeneral)
        }
        else {
            commandToSend = ScanNDEFCommand(timeout: 0, pollingMode: PollingMode.pollForGeneral)
        }
        
        TappyBleManager.shared().tappyBle?.setResponseListener(listener: listener)
        TappyBleManager.shared().tappyBle?.sendMessage(message: commandToSend)
        
        NSLog("Waiting for tap...")
        viewControllerToToast?.view.makeToast("Waiting for tap...")
    }
    else {
        NSLog("Tappy not ready")
    }
}

func WriteTextToNDEF (listener: @escaping (TCMPMessage) -> (),
                      viewControllerToToast: UIViewController?,
                      lockTag: LockingMode = LockingMode.DONT_LOCK_TAG,
                      text: String) {
    if TappyBleManager.shared().tappyBle?.getLatestStatus() == TappyStatus.STATUS_READY {
        let commandToSend : TCMPMessage = WriteNDEFTextCommand(timeout: 0, lockTag: lockTag, text: text)
        
        TappyBleManager.shared().tappyBle?.setResponseListener(listener: listener)
        TappyBleManager.shared().tappyBle?.sendMessage(message: commandToSend)
        NSLog("Waiting for tap...")
        viewControllerToToast?.view.makeToast("Waiting for tap...")
    }
    else {
        NSLog("Tappy not ready")
    }
}

func WriteUriToNDEF (listener: @escaping (TCMPMessage) -> (),
                     viewControllerToToast: UIViewController? ,
                     lockTag: LockingMode = LockingMode.DONT_LOCK_TAG,
                     uri: String) {
    if TappyBleManager.shared().tappyBle?.getLatestStatus() == TappyStatus.STATUS_READY {
        let commandToSend : TCMPMessage = WriteNDEFUriCommand(timeout: 0, lockTag: lockTag, uriStringWithPrefix: uri)
        
        TappyBleManager.shared().tappyBle?.setResponseListener(listener: listener)
        TappyBleManager.shared().tappyBle?.sendMessage(message: commandToSend)
        NSLog("Waiting for tap...")
        viewControllerToToast?.view.makeToast("Waiting for tap...")
        }
        else {
            NSLog("Tappy not ready")
        }
}

func WriteCustomNDEF (listener: @escaping (TCMPMessage) -> (),
                     viewControllerToToast: UIViewController? ,
                     lockTag: LockingMode = LockingMode.DONT_LOCK_TAG,
                     rawNdef: [UInt8]) {
    if TappyBleManager.shared().tappyBle?.getLatestStatus() == TappyStatus.STATUS_READY {
        let commandToSend : TCMPMessage = WriteCustomNDEFCommand(timeout: 0, lockTag: lockTag, rawNdef: rawNdef)
        
        TappyBleManager.shared().tappyBle?.setResponseListener(listener: listener)
        TappyBleManager.shared().tappyBle?.sendMessage(message: commandToSend)
        NSLog("Waiting for tap...")
        viewControllerToToast?.view.makeToast("Waiting for tap...")
    }
    else {
        NSLog("Tappy not ready")
    }
}

func WriteRawNDEF (listener: @escaping (TCMPMessage) -> (),
                      viewControllerToToast: UIViewController? ,
                      lockTag: LockingMode = LockingMode.DONT_LOCK_TAG,
                      hexString: String) {
    if TappyBleManager.shared().tappyBle?.getLatestStatus() == TappyStatus.STATUS_READY {
        let rawNdef : [UInt8] = hexString.hexToBytes
        let commandToSend : TCMPMessage = WriteCustomNDEFCommand(timeout: 0, lockTag: lockTag, rawNdef: rawNdef)
        
        TappyBleManager.shared().tappyBle?.setResponseListener(listener: listener)
        TappyBleManager.shared().tappyBle?.sendMessage(message: commandToSend)
        NSLog("Waiting for tap...")
        viewControllerToToast?.view.makeToast("Waiting for tap...")
    }
    else {
        NSLog("Tappy not ready")
    }
}

func ReadTag(listener: @escaping (TCMPMessage) -> (), viewControllerToToast: UIViewController?, isContinuousScan: Bool = false) {
    if TappyBleManager.shared().tappyBle?.getLatestStatus() == TappyStatus.STATUS_READY {
        let commandToSend : TCMPMessage
        if isContinuousScan {
            commandToSend = StreamTagCommand(timeout: 0, pollingMode: PollingMode.pollForGeneral)
        }
        else {
            commandToSend = ScanTagCommand(timeout: 0, pollingMode: PollingMode.pollForGeneral)
        }
        
        TappyBleManager.shared().tappyBle?.setResponseListener(listener: listener)
        TappyBleManager.shared().tappyBle?.sendMessage(message: commandToSend)
        
        NSLog("Waiting for tap...")
        viewControllerToToast?.view.makeToast("Waiting for tap...")
    }
    else {
        NSLog("Tappy not ready")
    }
}

class LocalNotification: NSObject, UNUserNotificationCenterDelegate {
    
    class func registerLocalNotifications(in application: UIApplication) {
            
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(wasAccepted, error) in
            if !wasAccepted {
                NSLog("Notification access denied.")
            }
        }
            
    }
        
    class func dispatchLocalNotification(title: String, body: String, seconds: TimeInterval, userInfo: [AnyHashable: Any]? = nil) {
        
            let date = Date(timeIntervalSinceNow: seconds)
            let triggerCal = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerCal, repeats: false)
            let content = UNMutableNotificationContent()
            
            content.title = title
            content.body = body
            content.categoryIdentifier = "category_tag_read"
        
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
    
        NSLog("WILL DISPATCH LOCAL NOTIFICATION IN " + String(format: "%f", seconds) + " SECONDS")
    }
}

func EnableAutoPolling(listener: @escaping (TCMPMessage) -> (), viewControllerToToast: UIViewController?,
                       scanMode: AutoPollingScanMode, heartbeatPeriod: UInt8, suppressBuzzer: Bool) {
    if TappyBleManager.shared().tappyBle?.getLatestStatus() == TappyStatus.STATUS_READY {
        let commandToSend: TCMPMessage? = AutoPollingCommand(
            scanMode: scanMode,
            heartbeatPeriod: heartbeatPeriod,
            suppressBuzzer: suppressBuzzer
        )
        
        if let unwrappedCommand = commandToSend {
            TappyBleManager.shared().tappyBle?.setResponseListener(listener: listener)
            TappyBleManager.shared().tappyBle?.sendMessage(message: unwrappedCommand)
        }
    } else {
        NSLog("Tappy not ready")
    }
}
