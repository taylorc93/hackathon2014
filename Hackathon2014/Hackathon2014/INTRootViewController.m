//
//  INTRootViewController.m
//  Hackathon2014
//
//  Created by Connor Taylor & Chris Penny on 10/25/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTRootViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "PdBase.h"

@implementation INTRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.editFlag = 0;
    self.instrumentVC = [self childViewControllers][0];
    self.settingsVC = [self childViewControllers][1];
    self.effectsVC = [self childViewControllers][2];
    self.settingsVC.instrumentVC = self.instrumentVC;
    self.effectsVC.instrumentVC = self.instrumentVC;
}

- (IBAction)toggleMode:(id)sender
{
    if (self.editFlag){
        self.editFlag = 0;
        [self.modeButton setTitle:@"Edit" forState:UIControlStateNormal];
    } else {
        self.editFlag = 1;
        [self.modeButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    [self.instrumentVC updateEditFlag:self.editFlag];
}

- (void)setLabelsNeedUpdate
{
    [self.settingsVC updateLabels];
}

@end
