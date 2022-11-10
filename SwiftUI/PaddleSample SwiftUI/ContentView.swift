//
//  ContentView.swift
//  PaddleSample SwiftUI
//
//  Created by Louis Harwood on 03/11/2022.
//

import SwiftUI
import Paddle

struct ContentView: View {
    let myPaddleVendorID = "YOUR VENDOR ID"
    let myPaddleProductID = "YOUR PRODUCT ID"
    let myPaddleAPIKey = "YOUR API KEY"
    let paddle : Paddle
    
    @State var productActivated = false
    @State private var reclaimLicense: String = ""
    @State private var reclaimAlert = false
    @State private var activationsCount = 0
    @State private var reclaimFinished = false
    
    init() {
        let defaultProductConfig = PADProductConfiguration()
        defaultProductConfig.productName = "My v4 Product"
        defaultProductConfig.vendorName = "My Company"
        
        
        
        paddle = Paddle.sharedInstance(withVendorID: myPaddleVendorID,
                                           apiKey: myPaddleAPIKey,
                                           productID: myPaddleProductID,
                                           configuration: defaultProductConfig,
                                       delegate:nil)!
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Button {
                self.purchaseMainProduct()
            } label: {
                Text("Purchase Product")
            }
            
            Button {
                if self.productActivated {
                    self.deactivateMainProduct()
                } else {
                    self.activateMainProduct(licenseCode: nil, email: nil)
                }
            } label: {
                if self.productActivated {
                    Text("Deactivate Product")
                } else {
                    Text("Activate Product")
                }
            }
            
            
            VStack(alignment: .leading) {
                        TextField("License Code to Reclaim", text: $reclaimLicense)
                        .alert("Reclaimed Activation", isPresented: $reclaimFinished) {
                                Button("Ok") { }
                            }
                
                        Button {
                            if reclaimLicense.count > 0 {
                                self.getActivationsCount(licenseCode: self.reclaimLicense)
                                reclaimAlert = true
                            } else {
                                self.getActivationsCount(licenseCode: nil)
                                reclaimAlert = true
                            }
                        } label: {
                            Text("Reclaim Activations")
                        }
                        .disabled(self.productActivated == false && self.reclaimLicense.count == 0)
                        .alert("There are \(activationsCount) activations", isPresented: $reclaimAlert) {
                                    Button("Deactivate Oldest") {
                                        if reclaimLicense.count > 0 {
                                            self.reclaimActivations(licenseCode: self.reclaimLicense)
                                        } else {
                                            self.reclaimActivations(licenseCode: (self.mainProduct()?.licenseCode)!)
                                        }
                                    }
                                    Button("Cancel") { }
                                }
                    }
            .padding()

        }
        .padding()
        .onAppear(perform: {
            self.isMainProductActivated()
        })
    }
    
    func purchaseMainProduct() {
        let displayConfiguration = PADDisplayConfiguration(PADDisplayType.window, hideNavigationButtons: true, parentWindow: nil)
        
        self.paddle.showCheckout(for: self.mainProduct()!, options: nil, displayConfiguration: displayConfiguration, checkoutStatusCompletion: { checkoutState, checkoutData in
            if checkoutState == PADCheckoutState.purchased {
                self.isMainProductActivated()
            }
        })
    }
    
    func activateMainProduct(licenseCode: String?, email: String?) {
        let displayConfiguration = PADDisplayConfiguration(PADDisplayType.window, hideNavigationButtons: true, parentWindow: nil)
        
        self.paddle.showLicenseActivationDialog(for: self.mainProduct()!, email: email, licenseCode: licenseCode, displayConfiguration: displayConfiguration, activationStatusCompletion: { activationState in
            if activationState == PADActivationState.activated {
                self.isMainProductActivated()
            }
        })
    }
    
    func deactivateMainProduct() {
        let displayConfiguration = PADDisplayConfiguration(PADDisplayType.window, hideNavigationButtons: true, parentWindow: nil)
        
        self.paddle.showLicenseActivationDialog(for: self.mainProduct()!, email: nil, licenseCode: nil, displayConfiguration:displayConfiguration, activationStatusCompletion: { activationState in
                self.isMainProductActivated()
                self.reclaimLicense = ""
        })
    }
    
    func reclaimActivations(licenseCode: String) {
        let mainProduct = self.mainProduct()!
        
        mainProduct.activations(forLicense: licenseCode) { activations, error in
            let activationsList = activations as? [[String:Any]]
            
            if let oldestActivation = activationsList?.first {
                mainProduct.deactivateActivation(oldestActivation["activation_id"] as! String, license: licenseCode) { deactivated, error in
                    self.reclaimFinished = true
                }
            }
        }
    }
    
    func getActivationsCount(licenseCode: String?) {
        let mainProduct = self.mainProduct()!
        
        let licenseToCheck = (licenseCode != nil) ? licenseCode : mainProduct.licenseCode
        
        mainProduct.activations(forLicense: licenseToCheck) { activations, error in
            self.activationsCount = activations?.count ?? 0
        }
    }
    
    func isMainProductActivated() {
        let mainProduct = self.mainProduct()!
        
        if mainProduct.activated {
            self.productActivated = true
            self.reclaimLicense = mainProduct.licenseCode ?? ""
            
            self.getActivationsCount(licenseCode: self.reclaimLicense)
            
            
            return
        }
        
        self.productActivated = false
    }
    
    func mainProductConfig()->PADProductConfiguration {
        let defaultProductConfig = PADProductConfiguration()
        defaultProductConfig.productName = "My v4 Product"
        defaultProductConfig.vendorName = "My Company"
        
        return defaultProductConfig
    }
    
    func mainProduct()->PADProduct? {
        let mainProduct = PADProduct(productID: myPaddleProductID, productType: PADProductType.sdkProduct, configuration:self.mainProductConfig()) ?? nil
        
        return mainProduct
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
