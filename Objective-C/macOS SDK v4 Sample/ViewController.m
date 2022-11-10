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

@interface ViewController () <PADProductDelegate, PaddleDelegate>

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
    
    Paddle *paddle = [Paddle sharedInstanceWithVendorID:PAD_VENDOR_ID
                                                 apiKey:PAD_API_KEY
                                              productID:PAD_SDK_PRODUCT_ID // Note that this must be an SDK product id!
                                          configuration:[AppConfig configurationForMainProduct]
                                               // The delegate should be set early to catch any errors and warnings.
                                               delegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activationsChanged:) name:@"activationsChanged" object:nil];
    
    [self checkActivations];
}

- (void)activationsChanged:(NSNotification *)notification {
    [self checkActivations];
}

- (void)checkActivations {
    PADProduct *mainProduct = [self mainProduct];
    if ([mainProduct activated]) {
        __block NSNumber *mainProductActivationCount;
        [mainProduct activationsForLicense:nil completion:^(NSArray * _Nullable activations, NSError * _Nullable error) {
                mainProductActivationCount = [NSNumber numberWithLong:[activations count]];
            if ([activations count] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.mainProductActivationCount setStringValue:[NSString stringWithFormat:@"Main Product has %d activations", mainProductActivationCount.intValue]];
                    self.mainProductActivationCount.hidden = NO;
                    [self.mainProductActivationReclaim setTitle:@"Deactivate Oldest"];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.mainProductActivationCount.hidden = YES;
                    [self.mainProductActivationReclaim setTitle:@"Reclaim Main Product Activations"];
                });
            }
            
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mainProductActivationCount.hidden = YES;
            [self.mainProductActivationReclaim setTitle:@"Reclaim Main Product Activations"];
        });
    }
    
    PADProduct *secondProduct = [self secondProduct];
    if ([secondProduct activated]) {
        __block NSNumber *secondProductActivationCount;
        [secondProduct activationsForLicense:nil completion:^(NSArray * _Nullable activations, NSError * _Nullable error) {
                secondProductActivationCount = [NSNumber numberWithLong:[activations count]];
            if ([activations count] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.secondProductActivationCount setStringValue:[NSString stringWithFormat:@"Second Product has %d activations", secondProductActivationCount.intValue]];
                    self.secondProductActivationCount.hidden = NO;
                    [self.secondProductActivationReclaim setTitle:@"Deactivate Oldest"];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.secondProductActivationCount.hidden = YES;
                    [self.secondProductActivationReclaim setTitle:@"Reclaim Second Product Activations"];
                });
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.secondProductActivationCount.hidden = YES;
            [self.secondProductActivationReclaim setTitle:@"Reclaim Second Product Activations"];
        });
    }
}

- (NSString *)promptForLicenseCode {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Please provide license code for product"];
    [alert addButtonWithTitle:@"Reclaim Activations"];
    [alert addButtonWithTitle:@"Cancel"];

    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [alert setAccessoryView:input];

    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        return [input stringValue];
    } else {
        return nil;
    }
}

- (void)reclaimActivationForLicense:(NSString *)licenseCode product:(PADProduct *)product activationId:(NSString *)activationId {
    [product deactivateActivation:activationId license:licenseCode completion:^(BOOL deactivated, NSError * _Nullable error) {
        NSAlert *myAlert = [NSAlert new];
        [myAlert setMessageText:@"Activation Deactivated"];
        [myAlert runModal];
        [self checkActivations];
    }];
}

- (IBAction)mainProductActivationReclaim:(id)sender {
    PADProduct *mainProduct = [self mainProduct];
    if ([mainProduct activated]) {
        [mainProduct activationsForLicense:nil completion:^(NSArray * _Nullable activations, NSError * _Nullable error) {
            [self reclaimActivationForLicense:[mainProduct licenseCode] product:mainProduct activationId:[[activations firstObject] objectForKey:@"activation_id"]];
        }];
    } else {
        NSString *licenseCode = [self promptForLicenseCode];
        
        if (licenseCode) {
            [mainProduct activationsForLicense:licenseCode completion:^(NSArray * _Nullable activations, NSError * _Nullable error) {
                NSNumber *activationsCount = [NSNumber numberWithLong:[activations count]];
                
                if ([activations count] > 0) {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:[NSString stringWithFormat:@"License has %@ activations", activationsCount]];
                    [alert addButtonWithTitle:@"Deactivate Oldest"];
                    [alert addButtonWithTitle:@"Cancel"];

                    NSInteger button = [alert runModal];
                    if (button == NSAlertFirstButtonReturn) {
                        [self reclaimActivationForLicense:licenseCode product:mainProduct activationId:[[activations firstObject] objectForKey:@"activation_id"]];
                    }
                } else {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:@"No Activations"];
                    [alert setInformativeText:@"There are no activations for this license"];
                    [alert addButtonWithTitle:@"OK"];

                    [alert runModal];
                }
            }];
        }
    }
}

- (IBAction)secondProductActivationReclaim:(id)sender {
    PADProduct *secondProduct = [self secondProduct];
    if ([secondProduct activated]) {
        [secondProduct activationsForLicense:nil completion:^(NSArray * _Nullable activations, NSError * _Nullable error) {
            [self reclaimActivationForLicense:[secondProduct licenseCode] product:secondProduct activationId:[[activations firstObject] objectForKey:@"activation_id"]];
        }];
    } else {
        NSString *licenseCode = [self promptForLicenseCode];
        
        if (licenseCode) {
            [secondProduct activationsForLicense:licenseCode completion:^(NSArray * _Nullable activations, NSError * _Nullable error) {
                NSNumber *activationsCount = [NSNumber numberWithLong:[activations count]];
                
                if ([activations count] > 0) {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:[NSString stringWithFormat:@"License has %@ activations", activationsCount]];
                    [alert addButtonWithTitle:@"Deactivate Oldest"];
                    [alert addButtonWithTitle:@"Cancel"];

                    NSInteger button = [alert runModal];
                    if (button == NSAlertFirstButtonReturn) {
                        [self reclaimActivationForLicense:licenseCode product:secondProduct activationId:[[activations firstObject] objectForKey:@"activation_id"]];
                    }
                } else {
                    NSAlert *alert = [[NSAlert alloc] init];
                    [alert setMessageText:@"No Activations"];
                    [alert setInformativeText:@"There are no activations for this license"];
                    [alert addButtonWithTitle:@"OK"];

                    [alert runModal];
                }
            }];
        }
    }
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
        
        Paddle.sharedInstance.delegate = self;
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
    
    [self checkActivations];
}

- (void)productDeactivated
{
    NSLog(@"Product Deactivated");
    if ([[self mainProduct] activated]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mainProductButton.title = @"Buy Main Product";
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.secondProductButton.title = @"Buy Second Product";
        });
    }
    
    [self checkActivations];
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
