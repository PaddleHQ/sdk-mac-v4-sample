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
                                          configuration:[AppConfig configurationForMainProduct]
                                               // The delegate should be set early to catch any errors and warnings.
                                               delegate:self];

    PADProduct *mainProduct = [[PADProduct alloc] initWithProductID:PAD_SDK_PRODUCT_ID
                                                    productType:PADProductTypeSDKProduct
                                                  configuration:[AppConfig configurationForMainProduct]];
    
    [mainProduct verifyActivationWithCompletion:^(PADVerificationState state, NSError * _Nullable error) {
        if (state == PADVerificationUnverified) {
            [mainProduct destroyActivation];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"activationsChanged" object:self];
        }
    }];
    
    PADProduct *secondProduct = [[PADProduct alloc] initWithProductID:PAD_SDK_SECOND_PRODUCT_ID
                                                    productType:PADProductTypeSDKProduct
                                                  configuration:[AppConfig configurationForSecondProduct]];
    
    [secondProduct verifyActivationWithCompletion:^(PADVerificationState state, NSError * _Nullable error) {
        if (state == PADVerificationUnverified) {
            [secondProduct destroyActivation];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"activationsChanged" object:self];
        }
    }];
    
    // The Paddle SDK is enforcing the trial for us. Just to be sure that the app is closed
    // when it should, we'll enable force-exit.
    paddle.canForceExit = YES;
}

#pragma mark - Paddle Delegate methods

- (PADDisplayConfiguration *)willShowPaddleUIType:(PADUIType)uiType
                                          product:(PADProduct *)product
{
    if (uiType == PADUIProduct) {
        return nil;
    }
    
    // We'll unconditionally display all configurable Paddle dialogs as sheets attached to the main window.
    return [PADDisplayConfiguration configuration:PADDisplayTypeWindow
                            hideNavigationButtons:NO
                                     parentWindow:nil];
}

- (void)paddleDidError:(NSError *)error
{
    // Log errors to file or a web service. In this case we'll simply log to console.
    NSLog(@"Paddle error occurred: %@", error);
}

- (BOOL)canAutoActivate:(PADProduct *)product
{
    // The UI is updated immediately after the activation, so the user will not be left in a state of confusion.
    return YES;
}

@end
