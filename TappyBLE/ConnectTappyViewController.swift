//
//  ConnectTappyController.swift
//  TappyBLE
//
//  Created by David Shalaby on 2019-03-13.
//  Copyright © 2021 TapTrack. All rights reserved.
//

import UIKit
import TCMPTappy
import UserNotifications
import CoreBluetooth

class ConnectTappyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate {
    
    var centralManager = CBCentralManager()
    var state : TappyBleScannerStatus = TappyBleScannerStatus.STATUS_CLOSED
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        resolveState()
        changeStateAndNotify(newState: state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(central == centralManager){
            NSLog("Discovered a peripheral, validating name... ")
            if(TappyBleDeviceDefinition.isTappyDeviceName(device: peripheral)){
                NSLog(String(format: "peripheral %@ has a valid name, passing to tappyFoundListener", arguments: [peripheral.name!]))
                let tappy: TappyBleDevice = TappyBleDevice(name: peripheral.name!, deviceId: peripheral.identifier)
                tappyBleFoundListener(tappyBleDevice: tappy)
            }else{
                NSLog("peripheral has invalid name, not a TappyBLE")
            }
        }else{
            NSLog("Unknown CBCM Discovered a peripheral")
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
    
    func stopScan(){
        centralManager.stopScan()
        resolveState()
        changeStateAndNotify(newState: state)
    }
    
    func resolveState(){
        if(centralManager.state == .poweredOff){
            NSLog("BLE is powered off")
            state = TappyBleScannerStatus.STATUS_POWERED_OFF
        }else if(centralManager.state == .unauthorized){
            NSLog("BLE is not authorized")
            state =  TappyBleScannerStatus.STATUS_NOT_AUTHORIZED
        }else if(centralManager.state == .unsupported){
            NSLog("BLE is not supported")
            state =  TappyBleScannerStatus.STATUS_NOT_SUPPORTED
        }else if(centralManager.state == .resetting){
            NSLog("BLE is resetting")
            state =  TappyBleScannerStatus.STATUS_RESETTING
        }else if(centralManager.state == .unknown){
            NSLog("BLE state is unknown")
            state =  TappyBleScannerStatus.STATUS_UNKNOWN
        }else if(centralManager.state == .poweredOn){
            NSLog("BLE is powered on")
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
    
    func changeStateAndNotify(newState: TappyBleScannerStatus){
        state = newState
        tappyBleScannerStatusListener(status: newState)
    }
    
    // MARK: Properties
    
    @IBOutlet weak var connectionStatusText: UITextField!
    @IBOutlet weak var tappyList: UITableView!
    
    var prevCellIndexPath : IndexPath?
    var prevConnectedMessage : String?
    
    var tappyListData : [TappyBleDevice] = []
    
    // MARK: Overrides
    
    override func viewDidAppear(_ animated: Bool) {
        tappyList.isHidden = true
        
        if let tappyBle = TappyBleManager.shared().tappyBle {
            if tappyBle.getLatestStatus() != TappyStatus.STATUS_READY {
                tappyListData = []
                tappyList.reloadData()
            }
        }
        else {
            TappyBLE.ShowTappyNotConnectedAlert(viewController: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectionStatusText.text = "No Tappy Connected"
        
        TappyBLE.addBorderToTableView(tableView: tappyList)
        tappyList.dataSource = self
        tappyList.delegate = self
        centralManager.delegate = self
    }
    
    // MARK: Actions
    
    @IBAction func scanForDevicesPressed(_ sender: Any) {
        if let tappyBle = TappyBleManager.shared().tappyBle {
            tappyBle.disconnect()
        }
        
        tappyListData = []
        tappyList.reloadData()

        if(startScan()) {
            connectionStatusText.text = "Scanning for 10 seconds..."
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: {
                /*
                 These two lines are to get the "other" CBCentralManager to attain a powered-on state before the user attempts to connect to a Tappy device.
                 This addresses the issue of the user first selecting the Tappy to connect but it failing the first time due to an API misuse issue, then, upon
                 selecting the device again, it working, because the origin connect function call snaps it into powered-on mode. By putting this scan & stop here,
                 it accomplishes the action before the user selects a device. It does not lock the thread as there is no delay. Note that this is a work-around.
                */
                TappyCentralManagerProvider.shared().centralManager.scanForPeripherals(withServices: [TappyBleDeviceDefinition.getSerialServiceUuid()], options: nil)
                TappyCentralManagerProvider.shared().centralManager.stopScan()
                
                self.stopScan()
                self.tappyList.isHidden = false
            })
        } else if (TappyBleManager.shared().tappyBle?.getLatestStatus() != TappyStatus.STATUS_READY) {
            connectionStatusText.text = "Not ready to scan"
        }
    }
    
    // MARK: Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tappyListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = tappyListData[indexPath.row].name()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.stopScan()
        
        tableView.deselectSelectedRow(animated: true)
        if TappyBleManager.shared().tappyBle?.getLatestStatus() == TappyStatus.STATUS_READY && indexPath != prevCellIndexPath {
            if let tappyBle = TappyBleManager.shared().tappyBle {
                tappyBle.disconnect()
                tableView.cellForRow(at: prevCellIndexPath!)?.accessoryType = .none
            }
        }
        let index = indexPath.row
        let tappyBleDevice = tappyListData[index]
        prevCellIndexPath = indexPath
        if let tappyBle = TappyBle.getTappyBle(centralManager: TappyCentralManagerProvider.shared().centralManager, device: tappyBleDevice) {
            TappyBleManager.shared().tappyBle = tappyBle
            TappyBleManager.shared().tappyBle?.setStatusListener(listener: tappyStatusListener)
            TappyBleManager.shared().tappyBle?.connect()
          
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        } else {
            connectionStatusText.text = "Failed to connect"
            NSLog(String(format: "Failed to initialize the TappyBleCommunicator with %@ with ID %@", arguments: [tappyBleDevice.name(), String(describing: tappyBleDevice.deviceId)]))
        }
    }
    
    // MARK: Listeners
    
    func tappyBleScannerStatusListener(status: TappyBleScannerStatus) {
        if status == TappyBleScannerStatus.STATUS_POWERED_ON {
            connectionStatusText.text = "Ready to scan"
        } else if status == TappyBleScannerStatus.STATUS_SCANNING {
            NSLog("TAPPYBLE SCANNER STATUS: Scanning")
        }
    }
    
    func tappyBleFoundListener(tappyBleDevice: TappyBleDevice) {
        tappyListData.append(tappyBleDevice)
        tappyList.reloadData()
        NSLog(tappyBleDevice.name() + " found")
    }
    
    func tappyStatusListener(status: TappyStatus) {
        if (status == TappyStatus.STATUS_CONNECTING) {
            if let tappyName: String = TappyBleManager.shared().tappyBle?.getCommunicator().getDeviceDescription() {
                connectionStatusText.text = "Connecting to " + tappyName
            } else {
                connectionStatusText.text = "Connecting"
            }
        } else if (status == TappyStatus.STATUS_READY) {
            if let tappyName: String = TappyBleManager.shared().tappyBle?.getCommunicator().getDeviceDescription() {
                /*Send some bytes to trigger the pairing dialog in iOS (for newer TappyBLEs) - this prompt is only presented to the user when data transmission is actually attempted*/
                TappyBleManager.shared().tappyBle?.getCommunicator().sendBytes(data: [0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00])
                connectionStatusText.text = "Connected to " + tappyName
                prevConnectedMessage = connectionStatusText.text
            } else {
                connectionStatusText.text = "Connected"
            }
        } else if (status == TappyStatus.STATUS_DISCONNECTED) {
            connectionStatusText.text = "Disconnected"
        } else {
            print("TAPPY STATUS: \(status)")
        }
    }
}
