//
//  INTSettingsViewController.m
//  Hackathon2014
//
//  Created by Connor Taylor on 10/26/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTSettingsViewController.h"
#import "INTRootViewController.h"
#import "PdBase.h"

@implementation INTSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.waveNum = 8;
}

- (IBAction)resetPreset:(id)sender
{
    [self.instrumentVC reset];
}

- (IBAction)addNote:(id)sender
{
    [self.instrumentVC addNote];
}

- (IBAction)deleteNote:(id)sender
{
    [self.instrumentVC deleteNote];
}

- (IBAction)incrementOctave:(id)sender
{
    if([self.instrumentVC incrementOctave]){
        NSString *octaveText = [NSString stringWithFormat:@"Octave: %d", self.instrumentVC.currentOctave];
        self.octaveLabel.text = octaveText;
        
    }
}

- (IBAction)decrementOctave:(id)sender
{
    if ([self.instrumentVC decrementOctave]){
        NSString *octaveText = [NSString stringWithFormat:@"Octave: %d", self.instrumentVC.currentOctave];
        self.octaveLabel.text = octaveText;
    }
}

- (IBAction)incrementNote:(id)sender
{
    [self.instrumentVC incrementNote];
    NSString *noteName = [self getNoteName:self.instrumentVC.currentNote];
    NSLog(@"%@", noteName);
    NSString *noteText = [NSString stringWithFormat:@"Note: %@", noteName];
    self.noteLabel.text = noteText;
}

- (IBAction)decrementNote:(id)sender
{
    [self.instrumentVC decrementNote];
    NSString *noteName = [self getNoteName:self.instrumentVC.currentNote];
    NSString *noteText = [NSString stringWithFormat:@"Note: %@", noteName];
    self.noteLabel.text = noteText;
}

- (IBAction)incrementWave:(id)sender
{
    if (self.waveNum < 16){
        self.waveNum++;
    }
    NSString *receiver = [NSString stringWithFormat:@"all"];
    NSArray *message = [NSArray arrayWithObjects:@"wave", [NSNumber numberWithInt:self.waveNum], nil];
    [PdBase sendList:message toReceiver:receiver];
    self.waveLabel.text = [NSString stringWithFormat:@"Wave: %d", self.waveNum];
}

- (IBAction)decrementWave:(id)sender
{
    if (self.waveNum > 0){
        self.waveNum--;
    }
    NSString *receiver = [NSString stringWithFormat:@"all"];
    NSArray *message = [NSArray arrayWithObjects:@"wave", [NSNumber numberWithInt:self.waveNum], nil];
    [PdBase sendList:message toReceiver:receiver];
    self.waveLabel.text = [NSString stringWithFormat:@"Wave: %d", self.waveNum];
}

- (IBAction)holdNote:(id)sender
{
    self.instrumentVC.currentNote.hold = !self.instrumentVC.currentNote.hold;
}

- (void)updateLabels
{
    NSString *noteName = [self getNoteName:self.instrumentVC.currentMidiNote];
    NSString *noteText = [NSString stringWithFormat:@"Note: %@", noteName];
    self.noteLabel.text = noteText;
    
    NSString *octaveText = [NSString stringWithFormat:@"Octave: %d", self.instrumentVC.currentOctave];
    self.octaveLabel.text = octaveText;
    
    [self.noteHold setOn:self.instrumentVC.currentNote.hold];
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
            return @"";
    }
}

@end
