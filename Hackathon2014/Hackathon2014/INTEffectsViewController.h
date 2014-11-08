//
//  INTEffectsViewController.h
//  Hackathon2014
//
//  Created by Connor Taylor on 10/25/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "INTSlider.h"
#import "INTInstrumentViewController.h"

@interface INTEffectsViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *chorusButton;
@property (nonatomic, strong) IBOutlet UIButton *tremoloButton;
@property (nonatomic, strong) IBOutlet UIButton *ringmodButton;
@property (nonatomic, strong) IBOutletCollection(INTSlider) NSArray *sliders;

@property (nonatomic, strong) INTInstrumentViewController *instrumentVC;
@property BOOL chorusPlaying;
@property BOOL tremeloPlaying;
@property BOOL ringmodPlaying;

@end
