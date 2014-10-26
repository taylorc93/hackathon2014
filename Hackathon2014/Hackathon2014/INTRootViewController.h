//
//  INTRootViewController.h
//  Hackathon2014
//
//  Created by Connor Taylor on 10/25/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INTInstrumentViewController.h"
#import "INTSettingsViewController.h"
#import "INTEffectsViewController.h"

@interface INTRootViewController : UIViewController

@property (nonatomic, strong) INTInstrumentViewController *instrumentVC;
@property (nonatomic, strong) INTSettingsViewController *settingsVC;
@property (nonatomic, strong) INTEffectsViewController * effectsVC;

@property (nonatomic, strong) IBOutlet UIButton *modeButton;
@property int editFlag; //set to 1 when in edit mode

- (void)setLabelsNeedUpdate;

@end
