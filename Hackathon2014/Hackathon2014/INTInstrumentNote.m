//
//  INTInstrumentNote.m
//  Hackathon2014
//
//  Created by Connor Taylor on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTInstrumentNote.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation INTInstrumentNote

- (instancetype)initWithFrame:(CGRect)frame
                      noteNum:(int)midiNum
                   noteOctave:(int)octave
{
    self = [super initWithFrame:frame];
    float width = frame.size.width;
    float height = frame.size.height;
        
    if (self){
        self.midiNum = midiNum;
        self.octave = octave;
        
        self.playing = NO;
        self.selected = NO;
        self.hold = NO;
        self.touched = NO;
        
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 2;
        
        [self getNoteName];
        [self setBackgroundColor];
        
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(width / 4 + 10, height / 4, width / 2, height / 2)];
//        noteLabel.textAlignment = NSTextAlignmentCenter;
//        noteLabel.center = self.center;
        noteLabel.text = self.noteName;
        [self addSubview:noteLabel];
    }
    return self;
}

- (int)getScaledMidiNum
{
    return self.midiNum + self.octave * 12;
}

- (void)getNoteName
{
    int noteNum = self.midiNum % 12;
    switch (noteNum) {
        case 0:
            self.noteName = @"C";
            break;
        case 1:
            self.noteName = @"C#";
            break;
        case 2:
            self.noteName = @"D";
            break;
        case 3:
            self.noteName = @"D#";
            break;
        case 4:
            self.noteName = @"E";
            break;
        case 5:
            self.noteName = @"F";
            break;
        case 6:
            self.noteName = @"F#";
            break;
        case 7:
            self.noteName = @"G";
            break;
        case 8:
            self.noteName = @"G#";
            break;
        case 9:
            self.noteName = @"A";
            break;
        case 10:
            self.noteName = @"A#";
            break;
        case 11:
            self.noteName = @"B";
            break;
        default:
            DDLogInfo(@"Incompatible Midi Num");
            break;
    }
}

- (void)setBackgroundColor
{
    switch (self.octave) {
        case 1:
            self.color = [UIColor colorWithRed:34.0 / 255.0 green:68.0 / 255.0 blue:85.0 / 255.0 alpha:0.1];
            break;
        case 2:
            self.color = [UIColor colorWithRed:214.0 / 255.0 green:51.0 / 255.0 blue:51.0 / 255.0 alpha:0.2];
            break;
        case 3:
            self.color = [UIColor colorWithRed:219.0 / 255.0 green:77.0 / 255.0 blue:77.0 / 255.0 alpha:0.4];
            break;
        case 4:
            self.color = [UIColor colorWithRed:78.0 / 255.0 green:118.0 / 255.0 blue:134.0 / 255.0 alpha:1.0];
            break;
        case 5:
            self.color = [UIColor colorWithRed:85.0 / 255.0 green:170.0 / 255.0 blue:170.0 / 255.0 alpha:1.0];
            break;
        case 6:
            self.color = [UIColor colorWithRed:169.0 / 255.0 green:204.0 / 255.0 blue:127.0 / 255.0 alpha:1.0];
            break;
        case 7:
            self.color = [UIColor colorWithRed:25.0 / 255.0 green:209.0 / 255.0 blue:255.0 / 255.0 alpha:1.0];
            break;
        default:
            DDLogError(@"Octave %d not in correct bounds 1-7", self.octave);
            break;
    }
    self.backgroundColor = self.color;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//- (void)panNote:(UIPanGestureRecognizer *)panRecognizer
//{
//    DDLogVerbose(@"Got gesture");
//}

@end
