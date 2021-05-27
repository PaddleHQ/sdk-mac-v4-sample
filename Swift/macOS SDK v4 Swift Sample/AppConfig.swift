//
//  AppConfig.swift
//  macOS SDK v4 Swift Sample
//
//  Created by Louis Harwood on 26/05/2021.
//  Copyright © 2021 Paddle. All rights reserved.
//

import Foundation
import Paddle

class AppConfig: NSObject {
    static var PAD_API_KEY = ""
    static let PAD_VENDOR_ID = ""
    static let PAD_SDK_PRODUCT_ID = ""
    static let PAD_SDK_SECOND_PRODUCT_ID = ""

    static let PAD_SDK_PRODUCT_NAME = "YOUR MAIN PRODUCT NAME"
    static let PAD_SDK_SECOND_PRODUCT_NAME = "YOUR SECOND PRODUCT NAME"
    
    class func configurationForMainProduct() -> PADProductConfiguration {
        let mainProductConfig = PADProductConfiguration()
        mainProductConfig.trialText = "Thank you for trying out the Random Number Generator 500"
        mainProductConfig.localizedTrialText = NSLocalizedString("Thank you for trying out the Random Number Generator 500", tableName: nil, bundle: Bundle.main, value:"", comment: "")
        mainProductConfig.trialType = PADProductTrialType.timeLimited
        mainProductConfig.trialLength = 14;
        mainProductConfig.price = 10;
        mainProductConfig.currency = "USD";
        mainProductConfig.imagePath = Bundle.main.path(forResource: "AppIcon", ofType: "png")
        
        return mainProductConfig
    }

    class func configurationForSecondProduct() -> PADProductConfiguration {
        let secondProductConfig = PADProductConfiguration()
        secondProductConfig.trialText = "Thank you for trying out the Second Product"
        secondProductConfig.localizedTrialText = NSLocalizedString("Thank you for trying out the Second Product", tableName: nil, bundle: Bundle.main, value:"", comment: "")
        secondProductConfig.trialType = PADProductTrialType.none
        secondProductConfig.price = 10;
        secondProductConfig.currency = "USD";
        secondProductConfig.imagePath = Bundle.main.path(forResource: "AppIcon", ofType: "png")
        
        return secondProductConfig
    }
}
