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

@interface INTRootViewController : UIViewController

@property (nonatomic, strong) INTInstrumentViewController *instrumentVC;
@property (nonatomic, strong) INTSettingsViewController *settingsVC;
@property (nonatomic, strong) IBOutlet UIButton *modeButton;
@property (nonatomic, strong) IBOutlet UIButton *chorusButton;
@property (nonatomic, strong) IBOutlet UIButton *tremoloButton;

@property int editFlag; //set to 1 when in edit mode
@property BOOL chorusPlaying;
@property BOOL tremeloPlaying;
@property int waveNum;

- (void)setLabelsNeedUpdate;

@end
