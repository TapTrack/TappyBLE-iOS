# TCMPTappy

[![Version](https://img.shields.io/cocoapods/v/TCMPTappy.svg?style=flat)](https://cocoapods.org/pods/TCMPTappy)
[![License](https://img.shields.io/cocoapods/l/TCMPTappy.svg?style=flat)](https://github.com/TapTrack/TCMPTappy-iOS/blob/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/TCMPTappy.svg?style=flat)](https://cocoapods.org/pods/TCMPTappy)
![Xcode](https://img.shields.io/badge/Xcode-10.2.1-brightgreen.svg)
![Swift](https://img.shields.io/badge/Swift-4.2-brightgreen.svg)

This is TapTrack's iOS SDK for TappyBLE NFC readers.

## Installation

```
pod 'TCMPTappy'
```

## Scanning for a TappyBLE

### Create a Scanner

To scan for TappyBLE NFC readers, you can create a `TappyBleScanner` and call the `startScan()` method.

Please note that this scanner is a utility provided for convenience. For more robust scanning, it is recommended that the application implement its own scanner using the CoreBluetooth's `CBCentralManager`. In the example below, the `TappyCentralManagerProvider` is passed to the `TappyBleScanner`. However, you can pass in your own central manager in your application.

```Swift
// Create the scanner.
let scanner: TappyBleScanner = TappyBleScanner(centralManager: TappyCentralManagerProvider.shared().centralManager)
```

### Add a Tappy Found Listener

Create a listener for when the `TappyBleScanner` detects a TappyBLE device.

```Swift
func tappyBleFoundListener(tappyBleDevice: TappyBleDevice) {
    scanner.stopScan()

    // The getTappyBle(centralManager:device:) method does an additional check to ensure that the 
    // detected device is indeed a TappyBLE device and not another device using the same Bluetooth 
    // module. If it finds that the device is not a TappyBLE reader, it will return nil.
    let tappyBle = TappyBle.getTappyBle(centralManager: TappyCentralManagerProvider.shared().centralManager, device: tappyBleDevice)

    // Upwrap the optional value returned by getTappyBle(centralManager:device:).
    if let tappyBleFound = tappyBle {
        // You can set TappyBLE status listeners for connection and disconnection events.
        tappyBleFound.setStatusListener(listener: tappyStatusListener)

        // Note that you must maintain a strong reference to the tappyBleFound object to access
        // it outside this function.

        tappyBleFound.connect()
    } else {
        NSLog(String(format: "Failed to initialize the TappyBleCommunicator with %@ with ID %@", 
            arguments: [tappyBleDevice.name(), String(describing :tappyBleDevice.deviceId)]))
    }
}
```

You can attach this listener to the `TappyBleScanner` using `setTappyFoundListener(listener:)`. Please note that you can only set one `tappyFoundListener` listener at a time.

```Swift
scanner.setTappyFoundListener(listener: tappyBleFoundListener)
```

### Start Scanning

To scan for devices, call the scanner's `startScan()` method.

**Note:** Although it is permitted, scanning for a `TappyBLE` before a `tappyFoundListener` is set accomplishes little since your application would not be alerted to any discovered `TappyBLE` devices.

```Swift
// startScan() returns a Bool indicating whether the scan started successfully.
let scanStarted: Bool = scanner.startScan()

if !scanStarted {
    NSLog("Bluetooth scanning could not be initialized.")
}
```

You can stop the scan by calling `scanner.stopScan()`. It is recommended that you stop the scan as soon as you've discovered the devices you're interested in. This preserves battery and follows Apple's recommended Bluetooth usage.

## Creating and Sending a Command

You can create a TCMP command using the constructors provided by the library.

```Swift
// TCMP command for scanning a single NDEF tag. Using the empty constructor sets the default
// scan parameters: scanning for Mifare(R) tags with no timeout.
let scanCommand: TCMPMessage = ScanTagCommand()

// TCMP command for writing an NDEF text record using default parameters (no timeout and not 
// locking the tag to read-only).
let writeCommand: TCMPMessage = WriteNDEFTextCommand(text: "hello world")

// TCMP command for writing an NDEF text record using custom parameters.
let writeCommand2: TCMPMessage = WriteNDEFTextCommand(timeout: 0x05, lockTag: LockingMode.DONT_LOCK_TAG, text: "hello world")
```

You can then send the command to the TappyBLE using the `sendMessage(message:)` method.

```Swift
tappyBle.sendMessage(message: scanCommand)
```

## Receiving a Response

You can resolve a response by calling the correct command family resolver. The example below shows a response listener that uses the `BasicNFCCommandResolver` to resolve the response received from the Tappy. Each command family has its own resolver that is used as required.

Please note that the command/response resolvers throw when unable to resolve a message, so the resolver call must be wrapped in a do-catch block.

```Swift
func responseListener(tcmpResponse: TCMPMessage) {
    var response: TCMPMessage

    do {
        response = try BasicNFCCommandResolver.resolveResponse(message: tcmpResponse)

        if let response = response as? NDEFFoundResponse {
            NSLog("NDEF messsage found: \(response.ndefMessage)")
        } else if let response = response as? BasicNfcApplicationErrorMessage {
            NSLog("Basic NFC error response: \(response.errorDescription)")
        } else if {
            // ...
            // Add additional tests for responses you are interested in
        }
    } catch {
        NSLog("Response is not part of the Basic NFC Command Family.")

        // No matter what command family is being used, the TappyBLE may return system
        // errors, such as communication errors or application errors.
        do {
            response = try SystemCommandResolver.resolveResponse(message: tcmpResponse)

            if let response = response as? SystemErrorResponse {
                NSLog("System communication error: \(response.getErrorDescription())")
            } else if let response = response as? SystemApplicationErrorResponse {
                NSLog("System application error: \(response.errorDescription)")
            }
        } catch {
            NSLog("Error: response not recognized.")
        }
    }
}
```

You can attach this listener to the `TappyBle` using `setResponseListener(listener:)`. Please note that you can only set one `responseListener` at a time.

```Swift
tappyBle.setResponseListener(listener: responseListener)
```

## Supported Features

* All framing and de-framing for data sent to and received from the Tappy reader

* TappyBLE support with Core Bluetooth (deployment target set to iOS v 8.0)
    * Scanning for TappyBLE readers
    * Connecting to TappyBLE readers
    * Sending commands and receiving responses in [TCMP format](https://docs.google.com/document/d/1MjHizibAd6Z1PGZAWnbStXnCBVggptx3TIh2HRqEluk/edit?usp=sharing)

* Supported command families
    * Basic NFC Command Family
    * System Command Family
    * Type 4 Tag Command Family
    * NTAG 21x Command family
