//
//  INTSettingsViewController.h
//  Hackathon2014
//
//  Created by Connor Taylor on 10/26/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INTInstrumentViewController.h"

@interface INTSettingsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *noteLabel;
@property (nonatomic, strong) IBOutlet UILabel *octaveLabel;
@property (nonatomic, strong) IBOutlet UILabel *waveLabel;

@property (nonatomic, weak) INTInstrumentViewController *instrumentVC;
@property int waveNum;

- (void)updateLabels;

@end
