//
//  ViewController.h
//  macOS SDK v4 Sample
//
//  Created by Paddle on 18/12/2018.
//  Copyright © 2018 Paddle.com LTD. All rights reserved.
//

@import Cocoa;

@interface ViewController : NSViewController

@property (weak) IBOutlet NSView *statusBar;

@property (weak) IBOutlet NSButton *secondProductButton;
@property (weak) IBOutlet NSButton *mainProductButton;

@property (weak) IBOutlet NSTextField *mainProductActivationCount;
@property (weak) IBOutlet NSTextField *secondProductActivationCount;

@property (weak) IBOutlet NSButton *mainProductActivationReclaim;
@property (weak) IBOutlet NSButton *secondProductActivationReclaim;

@end
