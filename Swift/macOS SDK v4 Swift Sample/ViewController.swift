//
//  ViewController.swift
//  macOS SDK v4 Swift Sample
//
//  Created by Louis Harwood on 29/04/2021.
//  Copyright © 2021 Paddle. All rights reserved.
//

import Cocoa
import Paddle

class ViewController: NSViewController, PADProductDelegate {
    @IBOutlet var mainProductButton: NSButton!
    @IBOutlet var secondProductButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func mainButtonClicked(sender: NSButton) {
        let mainProduct = mainProduct()
        
        if mainProduct.activated {
            mainProduct.deactivate { deactivated, error in
                print("Error")
            }
        } else {
            Paddle.sharedInstance()?.showCheckout(for: mainProduct, options: nil, checkoutStatusCompletion: nil)
        }
    }
    
    @IBAction func secondButtonClicked(sender: NSButton) {
        let secondProduct = secondProduct()
        
        if secondProduct.activated {
            secondProduct.deactivate { deactivated, error in
                print("Error")
            }
        } else {
            Paddle.sharedInstance()?.showCheckout(for: secondProduct, options: nil, checkoutStatusCompletion: nil)
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
    
    func productActivated() {
        if mainProduct().activated {
            DispatchQueue.main.async {
                self.mainProductButton.title = "Deactivate Main Product"
            }
        } else {
            DispatchQueue.main.async {
                self.secondProductButton.title = "Deactivate Second Product"
            }
        }
    }
    
    func productDeactivated() {
        if mainProduct().activated {
            DispatchQueue.main.async {
                self.mainProductButton.title = "Buy Main Product"
            }
        } else {
            DispatchQueue.main.async {
                self.secondProductButton.title = "Buy Second Product"
            }
        }
    }

}

