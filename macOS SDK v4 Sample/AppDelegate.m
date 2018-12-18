//
//  AppDelegate.m
//  macOS SDK v4 Sample
//
//  Created by Paddle on 18/12/2018.
//  Copyright © 2018 Paddle.com LTD. All rights reserved.
//

#import "AppDelegate.h"
#import "AppConfig.h"
@import Paddle;

@interface AppDelegate () <PaddleDelegate>

@property BOOL mainProductActivated;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Enable debugging so we can see what the Paddle SDK is doing.
    [Paddle enableDebug];

    // Initialize Paddle.
    Paddle *paddle = [Paddle sharedInstanceWithVendorID:PAD_VENDOR_ID
                                                 apiKey:PAD_API_KEY
                                              productID:PAD_SDK_PRODUCT_ID // Note that this must be an SDK product id!
                                          configuration:[AppConfig configurationForMainProduct]];

    // The delegate should be set early to catch any errors and warnings.
    paddle.delegate = self;

    // The Paddle SDK is enforcing the trial for us. Just to be sure that the app is closed
    // when it should, we'll enable force-exit.
    paddle.canForceExit = YES;

    // Track whether the SDK product has been activated.
    PADProduct *mainProduct = [[PADProduct alloc] initWithProductID:PAD_SDK_PRODUCT_ID
                                                        productType:PADProductTypeSDKProduct
                                                      configuration:[AppConfig configurationForMainProduct]];
    self.mainProductActivated = mainProduct.activated;
}

#pragma mark - Paddle Delegate methods

- (PADDisplayConfiguration *)willShowPaddleUIType:(PADUIType)uiType
                                          product:(PADProduct *)product
{
    // We'll unconditionally display all configurable Paddle dialogs as sheets attached to the main window.
    return [PADDisplayConfiguration configuration:PADDisplayTypeSheet
                            hideNavigationButtons:NO
                                     parentWindow:NSApp.mainWindow];
}

- (void)paddleDidError:(NSError *)error
{
    // Log errors to file or a web service. In this case we'll simply log to console.
    NSLog(@"Paddle error occurred: %@", error);
}

- (void)didDismissPaddleUIType:(PADUIType)uiType
               triggeredUIType:(PADTriggeredUIType)triggeredUIType
                       product:(PADProduct *)product
{
    if (uiType == PADUILicense) {
        // When the license dialog has been closed, the activation status could have changed.
        // We've stored the activation status on app launch so that we can compare to the current status
        // now. If the status has changed, notify any listeners.

        NSNotificationName sendNotificationName;

        if (product.activated && !self.mainProductActivated) {
            sendNotificationName = PAD_PRODUCT_ACTIVATED;
        } else if (!product.activated && self.mainProductActivated) {
            sendNotificationName = PAD_PRODUCT_DEACTIVATED;
        }

        if (sendNotificationName) {
            [[NSNotificationCenter defaultCenter] postNotificationName:sendNotificationName
                                                                object:nil
                                                              userInfo:@{ @"product" : product }];
        }
    }
}

@end
