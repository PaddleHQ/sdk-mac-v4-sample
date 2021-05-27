//
//  ViewController.m
//  macOS SDK v4 Sample
//
//  Created by Paddle on 18/12/2018.
//  Copyright © 2018 Paddle.com LTD. All rights reserved.
//

#import "ViewController.h"
#import "AppConfig.h"
#include <stdlib.h>
@import Paddle;

@interface ViewController () <PADProductDelegate>

/**
 * @discussion Track whether there is a verification of the local activation in progress.
 * We don't want to verify the activation multiple times simultaneously, as that's unnecessary
 * use of bandwidth.
 */
@property BOOL verificationInProcess;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}



#pragma mark - Status button handlers

- (IBAction)upgradeButtonClicked:(id)sender
{
    PADProduct *mainProduct = [self mainProduct];
    
    if ([mainProduct activated]) {
        [mainProduct deactivateWithCompletion:^(BOOL deactivated, NSError * _Nullable error) {
            NSLog(@"Error? %@", error);
        }];
    } else {
        // Show the checkout to allow the user to purchase the product. The checkout completion is not
        // vital to us here: we want to track activations and deactivations but we're already doing that
        // through the `AppDelegate`. See `didDismissPaddleUIType:triggeredUIType:product:` of `AppDelegate`.
        [Paddle.sharedInstance showCheckoutForProduct:mainProduct
                                              options:nil
                             checkoutStatusCompletion:nil];
    }
}

- (IBAction)forgottenLicenseButtonClicked:(id)sender
{
    [Paddle.sharedInstance showLicenseRecoveryForProduct:[self mainProduct]
                                              completion:^(BOOL recoveryEmailSent, NSError *_Nullable error) {
                                                  if (recoveryEmailSent) {
                                                      // The user should receive an email with licenses, if any, soon.
                                                      // Open the license dialog so they can enter their license.
                                                      [Paddle.sharedInstance showLicenseActivationDialogForProduct:[self mainProduct]
                                                                                                             email:nil
                                                                                                       licenseCode:nil
                                                                                        activationStatusCompletion:nil];
                                                  }
                                              }];
}

- (IBAction)secondProductButtonClicked:(id)sender
{
    PADProduct *secondProduct = [self secondProduct];
    
    if ([secondProduct activated]) {
        [secondProduct deactivateWithCompletion:^(BOOL deactivated, NSError * _Nullable error) {
            NSLog(@"Error? %@", error);
        }];
    } else {
        [Paddle.sharedInstance showCheckoutForProduct:secondProduct options:nil checkoutStatusCompletion:nil];
    }
}

#pragma mark - Paddle helper methods

- (PADProduct *)mainProduct
{
    PADProduct *product = [[PADProduct alloc] initWithProductID:PAD_SDK_PRODUCT_ID
                                                    productType:PADProductTypeSDKProduct
                                                  configuration:[AppConfig configurationForMainProduct]];
    product.delegate = self;
    product.localizedTrialText = NSLocalizedStringFromTableInBundle(@"Thank you for trying out the Random Number Generator 500", nil, [NSBundle mainBundle], nil);
    return product;
}

- (PADProduct *)secondProduct
{
    PADProduct *product = [[PADProduct alloc] initWithProductID:PAD_SDK_SECOND_PRODUCT_ID
                                                    productType:PADProductTypeSDKProduct
                                                  configuration:[AppConfig configurationForSecondProduct]];
    product.delegate = self;

    return product;
}

#pragma mark - PADProductDelegate handlers

- (void)productActivated
{
    if ([[self mainProduct] activated]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mainProductButton.title = @"Deactivate Main Product";
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.secondProductButton.title = @"Deactivate Second Product";
        });
    }
}

- (void)productDeactivated
{
    if ([[self mainProduct] activated]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mainProductButton.title = @"Buy Main Product";
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.secondProductButton.title = @"Buy Second Product";
        });
    }
}


- (void)notifyUserOfRemoteDeactivation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *unverifiedAlert = [[NSAlert alloc] init];
        unverifiedAlert.informativeText = NSLocalizedStringFromTableInBundle(@"Your license has been deactivated remotely. Please reactivate your license or contact support if you need assistance.", nil, [NSBundle bundleForClass:[self class]], nil);
        [unverifiedAlert runModal];
    });
}

@end
