//
//  DeactivateViewController.swift
//  macOS SDK v4 Swift Sample
//
//  Created by Louis Harwood on 27/05/2021.
//  Copyright © 2021 Paddle. All rights reserved.
//

import Foundation
import Cocoa
import Paddle

class DeactivateViewController: NSViewController, PADProductDelegate {
    @IBOutlet var productSelection: NSPopUpButton!
    
    override func viewDidLoad() {
        if mainProduct().activated {
            productSelection.item(at: 0)?.isEnabled = false
        }
        
        if secondProduct().activated {
            productSelection.item(at: 1)?.isEnabled = false
        }
    }
    
    @IBAction func cancelButton(sender: NSButton) {
        view.window?.close()
    }
    
    @IBAction func nextButton(sender: NSButton) {
        if productSelection.indexOfSelectedItem == 0 {
            Paddle.sharedInstance()?.showLicenseActivationDialog(for: mainProduct(), email: nil, licenseCode: nil, activationStatusCompletion: { activationState in
                self.view.window?.close()
            })
        } else {
            Paddle.sharedInstance()?.showLicenseActivationDialog(for: secondProduct(), email: nil, licenseCode: nil, activationStatusCompletion: { activationState in
                self.view.window?.close()
            })
        }
    }
    
    
    func mainProduct() -> PADProduct {
        let product = PADProduct.init(productID: AppConfig.PAD_SDK_PRODUCT_ID, productType: PADProductType.sdkProduct, configuration: AppConfig.configurationForMainProduct())
        product?.delegate = self
        
        return product!
    }
    
    func secondProduct() -> PADProduct {
        let product = PADProduct.init(productID: AppConfig.PAD_SDK_SECOND_PRODUCT_ID, productType: PADProductType.sdkProduct, configuration: AppConfig.configurationForSecondProduct())
        product?.delegate = self
        
        return product!
    }
}
