//
//  LaunchUrlViewController.swift
//  TappyBLE
//
//  Created by David Shalaby on 2019-03-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import UIKit
import TCMPTappy
import WebKit
import NdefLibrary

class LaunchUrlViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {

    //MARK: Properties
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UIToolbar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var numURLsReceived = 0
    var numURLsStarted = 0
    var numURLsFinished = 0
    
    var lastOffsetY: CGFloat = 0
    
    override func viewDidAppear(_ animated: Bool) {
        if let tappyBle = TappyBleManager.shared().tappyBle {
            if tappyBle.getLatestStatus() == TappyStatus.STATUS_READY {
                TappyBLE.ReadNDEF(listener: defaultResponseListener, viewControllerToToast: self, isContinuousScan: true)
            }
            else {
                TappyBLE.ShowTappyNotConnectedAlert(viewController: self)
            }
        }
        else {
            TappyBLE.ShowTappyNotConnectedAlert(viewController: self)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let tappyBle = TappyBleManager.shared().tappyBle {
            if tappyBle.getLatestStatus() == TappyStatus.STATUS_READY {
                let stopCmd : TCMPMessage = StopCommand()
                TappyBleManager.shared().tappyBle?.sendMessage(message: stopCmd)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        launchURL(string: "https://www.taptrack.com/store/tappy-ble")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        activityIndicator.startAnimating()
        numURLsStarted = numURLsStarted + 1
        print("Num URLs Started: ", numURLsStarted)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        updateNavigation()
        numURLsFinished = numURLsFinished + 1
        print("Num URLs Finished: ", numURLsFinished)
        if numURLsReceived != numURLsStarted - 1 && numURLsReceived != numURLsFinished - 1 {
            print("OUCH")
        }
    }
    
    // MARK: Actions
    
    @IBAction func back(sender: UIBarButtonItem) {
        webView.goBack()
    }

    @IBAction func forward(sender: UIBarButtonItem) {
        webView.goForward()
    }

    @IBAction func reload(sender: UIBarButtonItem) {
        webView.reload()
    }
    
    // MARK: Delegate Methods
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let hide = scrollView.contentOffset.y > self.lastOffsetY
        self.navigationController?.setToolbarHidden(hide, animated: true)
        navigationBar.isHidden = hide
    }
    
    // MARK: Listeners
    
    func defaultResponseListener(tcmpResponse : TCMPMessage) {
        NSLog("Received a valid message from Tappy")
        //let resolver : BasicNFCCommandResolver = BasicNFCCommandResolver()
        var response : TCMPMessage
        
        
        do {
            try response = BasicNFCCommandResolver.resolveResponse(message: tcmpResponse)
            if response is BasicNfcApplicationErrorMessage {
                NSLog("Response is a basic NFC application error")
            } else if response is TagWrittenResponse {
                NSLog("Response is tag written response")
            } else if let tagReadResponse = response as? NDEFFoundResponse {
                NSLog("Response is NDEF found response")
                
                do {
                    try tagReadResponse.parsePayload(payload: tcmpResponse.payload) //no need to handle exception here since the resolver would not have returned otherwise
                    
                    let ndefMessage = Ndef.CreateNdefMessage(rawByteArray: tagReadResponse.ndefMessage)
                    
                    var records : [NdefRecord] = [];
                    if let unwrappedMessage = ndefMessage {
                        records = unwrappedMessage.records;
                    }
                    
                    if let uriRecord = records[0] as? UriRecord {
                        let url = uriRecord.uri
                        
                        numURLsReceived += 1
                        print("Num URLs Received: ", String(numURLsReceived))
                        
                        let urlObject = URL(string: url);
                        if let launchableUrl = urlObject {
                            launchURL(url: launchableUrl)
                            if url.starts(with: "https://") {
                                NSLog("URL launched")
                            } else {
                                NSLog("URL valid but not https (over SSL), so probably not launchable")
                                self.view.makeToast("Link must load using https (secure)")
                            }
                        } else {
                            NSLog("error launching URI")
                        }
                    } else {
                        NSLog("NFC tag did not contain a URI")
                    }
                } catch {
                    NSLog("TCMP message parsing failed")
                }
            } else {
                NSLog("Response is something the basic NFC resolver doesn't support yet")
            }
        } catch {
            NSLog("Message resolution failed")
        }
    }
    
    // MARK: Helper functions
    
    func showTappyNotConnectedAlert() {
        let alertController = UIAlertController(title: "TappyBLE", message:
            "TappyBLE not connected", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }

    func launchURL(url: URL) {
        webView.load(URLRequest(url: url))
        print("Launching URL: ", webView.isLoading)
    }
    
    func launchURL(string: String) {
        webView.load(URLRequest(url: URL(string: string)!))
    }
    
    func updateNavigation() {
        if webView.canGoBack {
            backButton.isEnabled = true
        } else {
            backButton.isEnabled = false
        }
        
        if webView.canGoForward {
            forwardButton.isEnabled = true
        } else {
            forwardButton.isEnabled = false
        }
    }
}

