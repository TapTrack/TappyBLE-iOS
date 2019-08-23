//
//  TappyBleManager.swift
//  TappyBLE
//
//  Created by David Shalaby on 2019-03-13.
//  Copyright © 2019 TapTrack. All rights reserved.
//

import Foundation
import TCMPTappy

class TappyBleManager {
    
    // MARK: - Properties
    
    private static var sharedTappyBleManager: TappyBleManager = {
        
        let tappyBleManager : TappyBleManager = TappyBleManager()
        return tappyBleManager
    }()
    
    // MARK: -
    
    public var tappyBle : TappyBle?
//    public var testPassed : Bool = false
    
    // Initialization
    
    private init() {
    }
    
    // MARK: - Accessors
    
    class func shared() -> TappyBleManager {
        return sharedTappyBleManager
    }
    
}
