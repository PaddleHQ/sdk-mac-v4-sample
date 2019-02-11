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

    // Listen for clicks on the random number label.
    NSGestureRecognizer *gesture = [[NSClickGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(randomNumberLabelClickedWithSender:)];
    [self.randomNumberLabel addGestureRecognizer:gesture];

    // Display the status bar if the user has not activated the product.
    // Depending on the status of the trial, we'll display a different message.
    PADProduct *mainProduct = [self mainProduct];
    self.statusBar.hidden = mainProduct.activated;
    [self setDisplayBasedOnProductStatus];

    dispatch_async(dispatch_get_main_queue(), ^{
        [mainProduct deactivateWithCompletion:^(BOOL deactivated, NSError *_Nullable error) {
            NSLog(@"error? %@", error);
        }];
    });
}

#pragma mark - Gesture handler

- (void)randomNumberLabelClickedWithSender:(NSGestureRecognizer *)sender
{
    // We might still be verifying the previous action.
    if (self.verificationInProcess) {
        NSLog(@"Skip action: we're still verifying a previous action.");
        return;
    }

    PADProduct *mainProduct = [self mainProduct];
    void (^performCoreOp)(void) = ^{
        self.randomNumberLabel.stringValue = [NSString stringWithFormat:@"%d", arc4random_uniform(1000)];
    };

    if (mainProduct.activated) {
        NSLog(@"Last successful verification took place at %@", mainProduct.lastSuccessfulVerifiedDate);

        // Verify the activation if it's been a while.
        if ([self dateDifferenceInHours:mainProduct.lastSuccessfulVerifiedDate toDate:[NSDate date]] >= 1) {
            NSLog(@"Last verification was over 1 hour ago. Verifying activation before continuing.");
            self.verificationInProcess = YES;
            [self setDisplayBasedOnProductStatus];

            [mainProduct verifyActivationWithCompletion:^(PADVerificationState state, NSError *_Nullable error) {
                self.verificationInProcess = NO;

                switch (state) {
                case PADVerificationVerified:
                    // All is well in the world.
                    NSLog(@"Successfully verified the activation");
                    performCoreOp();
                    break;
                case PADVerificationNoActivation:
                    // Technically this shouldn't happen as we already checked that the activation exists.
                    // Let's make sure the app is displaying the status of the product correctly.
                    NSLog(@"There is no local activation somehow");
                    [self setDisplayBasedOnProductStatus];
                    break;
                case PADVerificationUnverified:
                    // The activation is no longer valid. Destroy it, let the user know and continue with
                    // the trial.
                    NSLog(@"The local activation is no longer valid. It will be destroyed");
                    [mainProduct destroyActivation];
                    [self setDisplayBasedOnProductStatus];
                    [self notifyUserOfRemoteDeactivation];
                    break;
                case PADVerificationUnableToVerify: {
                    // Verify that the last successful verify date is valid.
                    // And then implement a cooldown strategy. In this case it's a 7 day cooldown period.

                    NSLog(@"The local activation could not be verified");

                    NSDate *startDate = mainProduct.lastSuccessfulVerifiedDate;
                    NSDate *endDate = [NSDate date];

                    // Ensure that the last successful verified date appears valid.
                    // As `compare:` "detects sub-second differences" the dates should not be the same.
                    // Equally we can't have verified the activation in the future.
                    if ([startDate compare:endDate] != NSOrderedAscending) {
                        // The last successfully verified date does not seem valid. If the time difference
                        // is less than 24 hours, a timezone change is possible. Other than that, tampering
                        // seems likely.
                        //
                        // In doubt, destroy the activation and ask the user to reactivate.
                        [mainProduct destroyActivation];
                        [self setDisplayBasedOnProductStatus];
                        return;
                    }

                    // Implement a cooldown period of 7 days: if the user has not gone online in the last
                    // 7 days, then destroy the activation and ask them to go online to re-activate.
                    NSLog(@"Last successful verification was %ld days ago", [self dateDifferenceInDays:startDate toDate:endDate]);
                    if ([self dateDifferenceInDays:startDate toDate:endDate] >= 7) {
                        [mainProduct destroyActivation];
                        [self setDisplayBasedOnProductStatus];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSAlert *unverifiedAlert = [[NSAlert alloc] init];
                            unverifiedAlert.informativeText = NSLocalizedStringFromTableInBundle(@"We haven't been able to verify your license in 7 days or more. Please go online to reactivate your license.", nil, [NSBundle bundleForClass:[self class]], nil);
                            [unverifiedAlert runModal];
                        });
                        return;
                    }

                    // The grace period continues, so the user can continue to use the core functionality.
                    performCoreOp();
                } break;
                }
            }];

            return;
        } else {
            // No need to verify. The product is activated. All's well.
            performCoreOp();
        }
    } else {
        [self setDisplayBasedOnProductStatus];

        if ([mainProduct.trialDaysRemaining intValue] > 0) {
            // The trial is still active, so we can go ahead of generate that random number.
            performCoreOp();
        }
    }
}

#pragma mark - Status button handlers

- (IBAction)upgradeButtonClicked:(id)sender
{
    // Show the checkout to allow the user to purchase the product. The checkout completion is not
    // vital to us here: we want to track activations and deactivations but we're already doing that
    // through the `AppDelegate`. See `didDismissPaddleUIType:triggeredUIType:product:` of `AppDelegate`.
    [Paddle.sharedInstance showCheckoutForProduct:[self mainProduct]
                                          options:nil
                         checkoutStatusCompletion:nil];
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

#pragma mark - PADProductDelegate handlers

- (void)productActivated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Clear the random number label to remove any warning like "Please purchase to continue…".
        self.randomNumberLabel.stringValue = @"";

        [self setDisplayBasedOnProductStatus];
    });
}

- (void)productDeactivated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDisplayBasedOnProductStatus];
    });
}

#pragma mark - Private methods

- (NSInteger)dateDifferenceInDays:(nonnull NSDate *)fromDateTime
                           toDate:(nonnull NSDate *)toDateTime
{
    return [[self dateDifference:fromDateTime toDate:toDateTime inUnit:NSCalendarUnitDay] day];
}

- (NSInteger)dateDifferenceInHours:(nonnull NSDate *)fromDateTime
                            toDate:(nonnull NSDate *)toDateTime
{
    return [[self dateDifference:fromDateTime toDate:toDateTime inUnit:NSCalendarUnitHour] hour];
}

- (nonnull NSDateComponents *)dateDifference:(nonnull NSDate *)fromDateTime
                                      toDate:(nonnull NSDate *)toDateTime
                                      inUnit:(NSCalendarUnit)calendarUnit
{
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [gregorian rangeOfUnit:calendarUnit startDate:&fromDate interval:nil forDate:fromDateTime];
    [gregorian rangeOfUnit:calendarUnit startDate:&toDate interval:nil forDate:toDateTime];
    return [gregorian components:calendarUnit
                        fromDate:fromDate
                          toDate:toDate
                         options:0];
}

/**
 * @brief Synchronize the view with the status of the product.
 * @discussion Because we are enforcing the trial and activation in this view, this method also
 * prevents further access to the app if the trial has expired. For this we are using the product
 * access dialog.
 */
- (void)setDisplayBasedOnProductStatus
{
    // Display the status bar if the user has not activated the product, and determine the
    // text of the core functionality label based on the activation and trial status.
    // Depending on the status of the trial, we'll display a different message.
    PADProduct *mainProduct = [self mainProduct];
    self.statusBar.hidden = mainProduct.activated;

    if (!mainProduct.activated) {
        NSString *statusBarMessage;
        if ([mainProduct.trialDaysRemaining intValue] > 0) {
            if ([mainProduct.trialDaysRemaining intValue] == 1) {
                statusBarMessage = NSLocalizedStringFromTableInBundle(@"You have 1 day left of your trial!", nil, [NSBundle bundleForClass:[self class]], nil);
            } else {
                statusBarMessage = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"You have %d days left of your trial!", nil, [NSBundle bundleForClass:[self class]], nil),
                                             [mainProduct.trialDaysRemaining intValue]];
            }

            self.randomNumberLabel.stringValue = @"";
        } else {
            statusBarMessage = NSLocalizedStringFromTableInBundle(@"Your trial has expired", nil, [NSBundle bundleForClass:[self class]], nil);
            self.randomNumberLabel.stringValue = NSLocalizedStringFromTableInBundle(@"Disabled. Please purchase product to continue.", nil, [NSBundle bundleForClass:[self class]], nil);

            // Enforce the trial.
            dispatch_async(dispatch_get_main_queue(), ^{
                [Paddle.sharedInstance showProductAccessDialogWithProduct:mainProduct];
            });
        }

        self.statusMessageLabel.stringValue = statusBarMessage;
    } else if (self.verificationInProcess) {
        NSLog(@"Still verifying the product");
        self.randomNumberLabel.stringValue = NSLocalizedStringFromTableInBundle(@"Thinking...", nil, [NSBundle bundleForClass:[self class]], nil);
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
