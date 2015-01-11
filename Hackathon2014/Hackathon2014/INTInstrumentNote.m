//
//  INTInstrumentNote.m
//  Hackathon2014
//
//  Created by Connor Taylor & Chris Penny on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTInstrumentNote.h"
#import "INTInstrumentViewController.h"
#import "PdBase.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation INTInstrumentNote {
    CGPoint originalTouchLocation;
}

- (instancetype)initWithFrame:(CGRect)frame
                      noteNum:(int)midiNum
                   noteOctave:(int)octave
                    channelId:(int)channelId
                     parentVC:(UIViewController *)parentVC;
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
        self.channelId = channelId;
        
        self.layer.cornerRadius = self.frame.size.width / 2;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 2;
        self.parentVC = parentVC;
        
        [self getNoteName];
        [self setBackgroundColor];
        
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(width / 4 + 10, height / 4, width / 2, height / 2)];
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    INTInstrumentViewController *instrumentVC = (INTInstrumentViewController *)self.parentVC;
    UITouch *originalTouch = (UITouch *)[touches anyObject];
    originalTouchLocation = [originalTouch locationInView:self];
    
    if (instrumentVC.editFlag){
        [instrumentVC selectNote:self];
    } else {
        if (self.playing){
            [self stop];
            self.playing = NO;
        } else {
            [self play];
            self.playing = YES;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *newTouch = (UITouch *)[touches anyObject];
    CGPoint newLocation = [newTouch locationInView:self];
    INTInstrumentViewController *instrumentVC = (INTInstrumentViewController *)self.parentVC;

    if (instrumentVC.editFlag){
        
        [self reposition:[self convertPoint:newLocation toView:instrumentVC.view]];
    } else {
        float diff = (originalTouchLocation.y - newLocation.y) / 127.0;
        if (diff > 1.0){
            diff = 1.0;
        } else if (diff < -1.0){
            diff = -1.0;
        }
        [self bendPitch:diff];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    INTInstrumentViewController *instrumentVC = (INTInstrumentViewController *)self.parentVC;
    if (instrumentVC.editFlag){
        NSLog(@"editting");
    } else {
        if (self.playing){
            [self stop];
            self.playing = NO;
        } else {
            [self play];
            self.playing = YES;
        }
    }
}

-(void)toggle
{
    INTInstrumentViewController *instrumentVC = (INTInstrumentViewController *)self.parentVC;
    NSLog(@"%d", instrumentVC.editFlag);
    if (instrumentVC.editFlag){
        NSLog(@"editting");
    } else {
        if (self.playing){
            [self stop];
            self.playing = NO;
        } else {
            [self play];
            self.playing = YES;
        }
    }
}

- (void)play
{
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObject:@"note"];
    [data addObject:[NSNumber numberWithInt:[self getScaledMidiNum]]];
    [data addObject:[NSNumber numberWithInt:50]];
    [PdBase sendList:data toReceiver:[NSString stringWithFormat:@"channel%d", self.channelId]];
    
    CABasicAnimation *animation;
    
    animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration=0.3;
    animation.repeatCount=HUGE_VALF;
    animation.autoreverses=NO;
    animation.fromValue=[NSNumber numberWithFloat:1.0];
    animation.toValue=[NSNumber numberWithFloat:0.3];
    [self.layer addAnimation:animation forKey:@"animatePlaying"];
}


- (void)bendPitch:(float)diff
{
    float bendNum = [self scaleBend:diff];
    NSArray *data = [NSArray arrayWithObjects:@"pitchbend", [NSNumber numberWithFloat:bendNum], nil];
    NSString *receiver = [NSString stringWithFormat:@"channel%d", self.channelId];

    [PdBase sendList:data toReceiver:receiver];
}

- (void)stop
{
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObject:@"note"];
    [data addObject:[NSNumber numberWithInt:[self getScaledMidiNum]]];
    [data addObject:[NSNumber numberWithInt:0]];
    [PdBase sendList:data toReceiver:[NSString stringWithFormat:@"channel%d", self.channelId]];
    
    [self.layer removeAllAnimations];
}

- (void)select
{
    if (self.selected){
        [self.layer removeAllAnimations];
        self.selected = NO;
    } else {
        CABasicAnimation *animation;
        animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration=0.3;
        animation.repeatCount=HUGE_VALF;
        animation.autoreverses=NO;
        animation.fromValue=[NSNumber numberWithFloat:1.0];
        animation.toValue=[NSNumber numberWithFloat:0.3];
        [self.layer addAnimation:animation forKey:@"animatePlaying"];
        
        self.selected = YES;
    }
}

- (void)reposition:(CGPoint)newCenter
{
    [UIView animateWithDuration:0.1 animations:^{
        [self setCenter:newCenter];
    }];
}

- (float)scaleBend:(float)value
{
    return 64 * pow(value, 3.0) + 64;
}

@end
