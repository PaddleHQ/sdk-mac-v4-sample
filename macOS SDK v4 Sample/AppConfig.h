//
//  AppConfig.h
//  macOS SDK v4 Sample
//
//  Created by Paddle on 19/12/2018.
//  Copyright © 2018 Paddle.com LTD. All rights reserved.
//

@import Foundation;
@import Paddle;

// Configuration values.
FOUNDATION_EXPORT NSString *const PAD_API_KEY;
FOUNDATION_EXPORT NSString *const PAD_VENDOR_ID;
FOUNDATION_EXPORT NSString *const PAD_SDK_PRODUCT_ID;

// `NSNotificationCenter` event to signal that a product has been activated.
FOUNDATION_EXPORT NSNotificationName const PAD_PRODUCT_ACTIVATED;

// `NSNotificationCenter` event to signal that a product has been deactivated.
FOUNDATION_EXPORT NSNotificationName const PAD_PRODUCT_DEACTIVATED;

NS_ASSUME_NONNULL_BEGIN

@interface AppConfig : NSObject

+ (PADProductConfiguration *)configurationForMainProduct;

@end

NS_ASSUME_NONNULL_END
