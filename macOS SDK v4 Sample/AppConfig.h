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
FOUNDATION_EXPORT NSString * _Nonnull const PAD_API_KEY;
FOUNDATION_EXPORT NSString * _Nonnull const PAD_VENDOR_ID;
FOUNDATION_EXPORT NSString * _Nonnull const PAD_SDK_PRODUCT_ID;

NS_ASSUME_NONNULL_BEGIN

@interface AppConfig : NSObject

+ (PADProductConfiguration *)configurationForMainProduct;

@end

NS_ASSUME_NONNULL_END
