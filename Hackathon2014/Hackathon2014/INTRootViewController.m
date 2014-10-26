//
//  INTRootViewController.m
//  Hackathon2014
//
//  Created by Connor Taylor on 10/25/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTRootViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "PdBase.h"

@implementation INTRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chorusPlaying = NO;
    self.tremeloPlaying = NO;
    self.waveNum = 8;
    self.editFlag = 0;
    self.instrumentVC = [self childViewControllers][0];
    self.settingsVC = [self childViewControllers][1];
    self.settingsVC.instrumentVC = self.instrumentVC;
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

- (IBAction)changeChorusRate:(UISlider *)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
    NSString *receiver = [NSString stringWithFormat:@"%d-chorus_rate", dollarZero];
    
    float value = sender.value;
    [PdBase sendFloat:value toReceiver:receiver];}

- (IBAction)changeChorusDepth:(UISlider *)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
    NSString *receiver = [NSString stringWithFormat:@"%d-chorus_depth", dollarZero];
    
    float value = sender.value;
    [PdBase sendFloat:value toReceiver:receiver];
}

- (IBAction)toggleChorus:(id)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
    NSString *receiver = [NSString stringWithFormat:@"%d-chorus_on", dollarZero];
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

- (IBAction)changeTremoloRate:(UISlider *)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
    NSString *receiver = [NSString stringWithFormat:@"%d-tremolo_rate", dollarZero];
    
    float value = sender.value;
    [PdBase sendFloat:value toReceiver:receiver];}

- (IBAction)changeTremoloDepth:(UISlider *)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
    NSString *receiver = [NSString stringWithFormat:@"%d-tremolo_depth", dollarZero];
    
    float value = sender.value;
    [PdBase sendFloat:value toReceiver:receiver];
}

- (IBAction)toggleTremolo:(id)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
    NSString *receiver = [NSString stringWithFormat:@"%d-tremolo_on", dollarZero];
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

- (void)setLabelsNeedUpdate
{
    [self.settingsVC updateLabels];
}

@end
