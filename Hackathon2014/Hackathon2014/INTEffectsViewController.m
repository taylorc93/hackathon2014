//
//  INTEffectsViewController.m
//  Hackathon2014
//
//  Created by Connor Taylor on 10/25/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTEffectsViewController.h"
#import "PdBase.h"

@implementation INTEffectsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.chorusPlaying = NO;
    self.tremeloPlaying = NO;
    self.ringmodPlaying = NO;
}

- (IBAction)changeChorusRate:(UISlider *)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
    NSString *receiver = [NSString stringWithFormat:@"chorus_rate"];
    
    float value = sender.value;
    [PdBase sendFloat:value toReceiver:receiver];}

- (IBAction)changeChorusDepth:(UISlider *)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
    NSString *receiver = [NSString stringWithFormat:@"chorus_depth"];
    
    float value = sender.value;
    [PdBase sendFloat:value toReceiver:receiver];
}

- (IBAction)toggleChorus:(id)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
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

- (IBAction)changeTremoloRate:(UISlider *)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
    NSString *receiver = [NSString stringWithFormat:@"tremolo_rate"];
    
    float value = sender.value;
    [PdBase sendFloat:value toReceiver:receiver];
}

- (IBAction)changeTremoloDepth:(UISlider *)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
    NSString *receiver = [NSString stringWithFormat:@"tremolo_depth"];
    
    float value = sender.value;
    [PdBase sendFloat:value toReceiver:receiver];
}

- (IBAction)toggleTremolo:(id)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
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

- (IBAction)changeRingModRate:(UISlider *)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
    NSString *receiver = [NSString stringWithFormat:@"ringmod_rate"];
    
    float value = sender.value;
    [PdBase sendFloat:value toReceiver:receiver];
}

- (IBAction)changeRingModDepth:(UISlider *)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
    NSString *receiver = [NSString stringWithFormat:@"ringmod_depth"];
    
    float value = sender.value;
    [PdBase sendFloat:value toReceiver:receiver];
}

- (IBAction)toggleRingMod:(id)sender
{
    int dollarZero = self.instrumentVC.dollarZero;
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
