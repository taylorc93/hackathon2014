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
                        color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    float width = frame.size.width;
    float height = frame.size.height;
    
    DDLogInfo(@"%f %f", width, height);
    
    if (self){
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(width / 4 + 8, height / 4, width / 2, height / 2)];
        self.color = color;
        self.midiNum = midiNum;
        [self getNoteName];
        noteLabel.text = self.noteName;
        
        [self addSubview:noteLabel];
    }
    return self;
}

- (void) getNoteName
{
    switch (self.midiNum) {
        case 64:
            self.noteName = @"C";
            break;
        case 65:
            self.noteName = @"D";
            break;
        case 66:
            self.noteName = @"E";
            break;
        case 67:
            self.noteName = @"F";
            break;
        case 68:
            self.noteName = @"G";
            break;
        case 69:
            self.noteName = @"A";
            break;
        case 70:
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
