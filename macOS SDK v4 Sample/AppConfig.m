//
//  AppConfig.m
//  macOS SDK v4 Sample
//
//  Created by Paddle on 19/12/2018.
//  Copyright © 2018 Paddle.com LTD. All rights reserved.
//

#import "AppConfig.h"

// ====================================================================
// PLEASE ENTER THESE VALUES BEFORE RUNNING THE APP.
//
NSString *const PAD_API_KEY = @"YOUR API KEY";
NSString *const PAD_VENDOR_ID = @"YOUR VENDOR ID";
NSString *const PAD_VENDOR_NAME = @"YOUR VENDOR NAME";
NSString *const PAD_SDK_PRODUCT_ID = @"YOUR MAIN PRODUCT ID";
NSString *const PAD_SDK_PRODUCT_NAME = @"YOUR MAIN PRODUCT NAME";
NSString *const PAD_SDK_SECOND_PRODUCT_ID = @"YOUR SECOND PRODUCT ID";
NSString *const PAD_SDK_SECOND_PRODUCT_NAME = @"YOUR SECOND PRODUCT NAME";
//
// ====================================================================

@implementation AppConfig

+ (PADProductConfiguration *)configurationForMainProduct
{
    PADProductConfiguration *config = [PADProductConfiguration configuration:PAD_SDK_PRODUCT_NAME
                                                                  vendorName:PAD_VENDOR_NAME];
    config.trialText = @"Thank you for trying out the Random Number Generator 500";
    config.localizedTrialText = NSLocalizedStringFromTableInBundle(@"Thank you for trying out the Random Number Generator 500", nil, [NSBundle mainBundle], nil);
    config.trialType = PADProductTrialTimeLimited;
    config.trialLength = @14;
    config.price = @10;
    config.currency = @"USD";
    config.imagePath = [NSBundle.mainBundle pathForResource:@"AppIcon" ofType:@"png"];

    return config;
}

+ (PADProductConfiguration *)configurationForSecondProduct
{
    PADProductConfiguration *config = [PADProductConfiguration configuration:PAD_SDK_SECOND_PRODUCT_NAME
                                                                  vendorName:PAD_VENDOR_NAME];
    config.trialText = @"Thank you for trying out the Second Product";
    config.localizedTrialText = NSLocalizedStringFromTableInBundle(@"Thank you for trying out the Second Product", nil, [NSBundle mainBundle], nil);
    config.trialType = PADProductTrialNone;
    config.price = @10;
    config.currency = @"USD";
    config.imagePath = [NSBundle.mainBundle pathForResource:@"AppIcon" ofType:@"png"];

    return config;
}

@end
