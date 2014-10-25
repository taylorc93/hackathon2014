//
//  INTRootViewController.h
//  Hackathon2014
//
//  Created by Connor Taylor on 10/25/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INTInstrumentViewController.h"

@interface INTRootViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *noteLabel;
@property (nonatomic, strong) IBOutlet UILabel *octaveLabel;
@property (nonatomic, strong) INTInstrumentViewController *instrumentVC;
@property int editFlag; //set to 1 when in edit mode
@property BOOL chorusPlaying;
@property BOOL tremeloPlaying;

- (void)setLabelsNeedUpdate;

@end
