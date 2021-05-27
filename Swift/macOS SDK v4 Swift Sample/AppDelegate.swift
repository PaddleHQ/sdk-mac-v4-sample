//
//  AppDelegate.swift
//  macOS SDK v4 Swift Sample
//
//  Created by Louis Harwood on 29/04/2021.
//  Copyright © 2021 Paddle. All rights reserved.
//

import Cocoa
import Paddle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, PaddleDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        Paddle.enableDebug()
        
        let paddle = Paddle.sharedInstance(withVendorID: AppConfig.PAD_VENDOR_ID, apiKey: AppConfig.PAD_API_KEY, productID: AppConfig.PAD_SDK_PRODUCT_ID, configuration: AppConfig.configurationForMainProduct(), delegate: self)
        
        paddle?.canForceExit = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    func willShowPaddle(_ uiType: PADUIType, product: PADProduct) -> PADDisplayConfiguration? {
        if uiType == PADUIType.product {
            return nil
        }
        
        return PADDisplayConfiguration.init(PADDisplayType.window, hideNavigationButtons: false, parentWindow: nil)
    }
    
    func paddleDidError(_ error: Error) {
        print("Paddle error occured: \(error)")
    }
    
    func canAutoActivate(_ product: PADProduct) -> Bool {
        return true
    }
}

