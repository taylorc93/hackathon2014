//
//  INTSettingsViewController.m
//  Hackathon2014
//
//  Created by Connor Taylor on 10/26/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTSettingsViewController.h"
#import "INTRootViewController.h"

@implementation INTSettingsViewController

- (IBAction)incrementOctave:(id)sender
{
    NSLog(@"OK");
    if([self.instrumentVC incrementOctave]){
        NSLog(@"OK");
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

- (void)updateLabels
{
    NSString *noteName = [self getNoteName:self.instrumentVC.currentNote];
    NSString *noteText = [NSString stringWithFormat:@"Note: %@", noteName];
    self.noteLabel.text = noteText;
    
    NSString *octaveText = [NSString stringWithFormat:@"Octave: %d", self.instrumentVC.currentOctave];
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
            return @"";
    }
}

@end
