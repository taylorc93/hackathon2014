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

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation INTRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chorusPlaying = NO;
    self.tremeloPlaying = NO;
    self.instrumentVC = [self childViewControllers][0];
}

- (IBAction)incrementOctave:(id)sender
{
    if([self.instrumentVC incrementOctave]){
        NSString *octaveText = [NSString stringWithFormat:@"Current Octave: %d", self.instrumentVC.currentOctave];
        self.octaveLabel.text = octaveText;
    }
}

- (IBAction)decrementOctave:(id)sender
{
    if ([self.instrumentVC decrementOctave]){
        NSString *octaveText = [NSString stringWithFormat:@"Current Octave: %d", self.instrumentVC.currentOctave];
        self.octaveLabel.text = octaveText;
    }
}

- (IBAction)incrementNote:(id)sender
{
    [self.instrumentVC incrementNote];
    NSString *noteName = [self getNoteName:self.instrumentVC.currentNote];
    NSString *noteText = [NSString stringWithFormat:@"Current Note: %@", noteName];
    self.noteLabel.text = noteText;
}

- (IBAction)decrementNote:(id)sender
{
    [self.instrumentVC decrementNote];
    NSString *noteName = [self getNoteName:self.instrumentVC.currentNote];
    NSString *noteText = [NSString stringWithFormat:@"Current Note: %@", noteName];
    self.noteLabel.text = noteText;
}

- (IBAction)addNote:(id)sender
{
    [self.instrumentVC addNote];
}

- (IBAction)toggleEditMode:(id)sender
{
    self.editFlag = 1;
    [self.instrumentVC updateEditFlag:self.editFlag];
}

- (IBAction)togglePlayMode:(id)sender
{
    self.editFlag = 0;
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
    } else {
        [PdBase sendFloat:1 toReceiver:receiver];
        self.chorusPlaying = YES;
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
    } else {
        [PdBase sendFloat:1 toReceiver:receiver];
        self.tremeloPlaying = YES;
    }
}

- (void)setLabelsNeedUpdate
{
    NSString *noteName = [self getNoteName:self.instrumentVC.currentNote];
    NSString *noteText = [NSString stringWithFormat:@"Current Note: %@", noteName];
    self.noteLabel.text = noteText;
    
    NSString *octaveText = [NSString stringWithFormat:@"Current Octave: %d", self.instrumentVC.currentOctave];
    self.octaveLabel.text = octaveText;
}

- (NSString *)getNoteName:(int)noteNum
{
    switch (noteNum) {
        case 0:
            return @"C";
        case 1:
            return @"C#";
        case 2:
            return @"D";
        case 3:
            return @"D#";
        case 4:
            return @"E";
        case 5:
            return @"F";
        case 6:
            return @"F#";
        case 7:
            return @"G";
        case 8:
            return @"G#";
        case 9:
            return @"A";
        case 10:
            return @"A#";
        case 11:
            return @"B";
        default:
            DDLogInfo(@"Incompatible Midi Num");
            return @"";
    }
}

@end
