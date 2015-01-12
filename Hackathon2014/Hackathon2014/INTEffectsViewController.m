//
//  INTEffectsViewController.m
//  Hackathon2014
//
//  Created by Connor Taylor & Chris Penny on 10/25/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTEffectsViewController.h"
#import "PdBase.h"

@implementation INTEffectsViewController

- (void)viewDidLoad
{
    UIColor *noteControlFillColor = [UIColor colorWithRed:245.0 / 255.0
                                                    green:245.0 / 255.0
                                                     blue:230.0 / 255.0
                                                    alpha:1.0];
    [super viewDidLoad];
    
    self.chorusPlaying = NO;
    self.tremeloPlaying = NO;
    self.ringmodPlaying = NO;
    
    NSArray *values = @[@"chorus_rate", @"chorus_depth", @"tremolo_rate",
                        @"tremolo_depth", @"ringmod_rate", @"ringmod_depth", @"all", @"autodelay"];
    int count = 0;
    for (INTSlider *slider in self.sliders){
        slider.receiver = values[count];
        count++;
        if([slider.receiver  isEqual: @"all"]) {
            slider.filler.backgroundColor = noteControlFillColor;
        }
    }
}

- (IBAction)toggleChorus:(id)sender
{
    NSString *receiver = [NSString stringWithFormat:@"chorus_on"];
    if (self.chorusPlaying){
        [PdBase sendFloat:0 toReceiver:receiver];
        self.chorusPlaying = NO;
        [self.chorusButton setTitle:@"Turn On" forState:UIControlStateNormal];
        
    } else {
        [PdBase sendFloat:1 toReceiver:receiver];
        self.chorusPlaying = YES;
        [self.chorusButton setTitle:@"Turn Off" forState:UIControlStateNormal];
    }
}

- (IBAction)toggleTremolo:(id)sender
{
    NSString *receiver = [NSString stringWithFormat:@"tremolo_on"];
    if (self.tremeloPlaying){
        [PdBase sendFloat:0 toReceiver:receiver];
        self.tremeloPlaying = NO;
        [self.tremoloButton setTitle:@"Turn On" forState:UIControlStateNormal];
    } else {
        [PdBase sendFloat:1 toReceiver:receiver];
        self.tremeloPlaying = YES;
        [self.tremoloButton setTitle:@"Turn Off" forState:UIControlStateNormal];
    }
}

- (IBAction)toggleRingMod:(id)sender
{
    NSString *receiver = [NSString stringWithFormat:@"ringmod_on"];
    if (self.ringmodPlaying){
        [PdBase sendFloat:0 toReceiver:receiver];
        self.ringmodPlaying = NO;
        [self.ringmodButton setTitle:@"Turn On" forState:UIControlStateNormal];
    } else {
        [PdBase sendFloat:1 toReceiver:receiver];
        self.ringmodPlaying = YES;
        [self.ringmodButton setTitle:@"Turn Off" forState:UIControlStateNormal];
    }
}

@end
