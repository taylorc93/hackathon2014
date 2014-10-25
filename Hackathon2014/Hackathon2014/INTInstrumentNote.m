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
                        color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    float width = frame.size.width;
    float height = frame.size.height;
        
    if (self){
        self.color = color;
        self.midiNum = midiNum;
        self.octave = octave;
        self.backgroundColor = color;
        
        [self getNoteName];
        
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(width / 4 + 8, height / 4, width / 2, height / 2)];
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
    DDLogVerbose(@"%d", noteNum);
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
