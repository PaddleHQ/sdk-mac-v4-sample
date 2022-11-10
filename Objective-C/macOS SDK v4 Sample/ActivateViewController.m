//
//  ActivateViewController.m
//  macOS SDK v4 Sample
//
//  Created by Louis Harwood on 25/11/2020.
//  Copyright © 2020 Paddle.com LTD. All rights reserved.
//

#import "ActivateViewController.h"
#import "AppConfig.h"
@import Paddle;

@interface ActivateViewController () <PADProductDelegate>

@end

@implementation ActivateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)cancelButton:(id)sender {
    [self.view.window close];
}

- (IBAction)nextButton:(id)sender {
    if (self.productSelection.indexOfSelectedItem == 0) {
        [Paddle.sharedInstance showLicenseActivationDialogForProduct:[self mainProduct] email:nil licenseCode:nil activationStatusCompletion:^(PADActivationState activationState) {
            if (activationState == PADActivationActivated) {
                [self.view.window close];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"activationsChanged" object:self];
            }
        }];
    } else {
        [Paddle.sharedInstance showLicenseActivationDialogForProduct:[self secondProduct] email:nil licenseCode:nil activationStatusCompletion:^(PADActivationState activationState) {
            if (activationState == PADActivationActivated) {
                [self.view.window close];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"activationsChanged" object:self];
            }
        }];
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

@end
