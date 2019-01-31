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
NSString *const PAD_API_KEY = @"";
NSString *const PAD_VENDOR_ID = @"";
NSString *const PAD_VENDOR_NAME = @"";
NSString *const PAD_SDK_PRODUCT_ID = @"";
NSString *const PAD_SDK_PRODUCT_NAME = @"";
//
// ====================================================================

@implementation AppConfig

+ (PADProductConfiguration *)configurationForMainProduct
{
    PADProductConfiguration *config = [PADProductConfiguration configuration:PAD_SDK_PRODUCT_NAME
                                                                  vendorName:PAD_VENDOR_NAME];
    config.trialText = @"Thank you for trying out the Random Number Generator 500";
    config.trialType = PADProductTrialTimeLimited;
    config.trialLength = @14;
    config.price = @10;
    config.currency = @"USD";
    config.imagePath = [NSBundle.mainBundle pathForResource:@"AppIcon" ofType:@"png"];

    return config;
}

@end
