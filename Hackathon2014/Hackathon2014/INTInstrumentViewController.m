//
//  INTInstrumentViewController.m
//  Hackathon2014
//
//  Created by Connor Taylor on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTRootViewController.h"
#import "INTInstrumentViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "PdBase.h"
#include "septagon_coordinates.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface INTInstrumentViewController ()

@property (nonatomic, strong) NSMutableArray *playingNotes;
@property (nonatomic, strong) UITouch *previousTouch;
@property BOOL touchStartedOnNote;
@property BOOL initializing;

@end

@implementation INTInstrumentViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    void *patch = [PdBase openFile:@"Main.pd"
                              path: [[NSBundle mainBundle] resourcePath]];
    if (!patch){
        DDLogError(@"Couldn't open patch");
    }
    
    self.dollarZero = [PdBase dollarZeroForFile:patch];
    self.currentNote = nil;
    self.currentOctave = 5;
    self.currentScale = @"C";
    self.notes = [[NSMutableArray alloc] init];
    self.playingNotes = [[NSMutableArray alloc] init];
    self.selectedNotes = [[NSMutableArray alloc] init];
    self.initializing = YES;
    self.touchStartedOnNote = NO;
}

// Cannot do this in viewWillLoad as bounds are not set properly at that time
- (void)viewWillLayoutSubviews
{
    if ([self.notes count] == 0 && self.initializing){
        [self initNotes];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initNotes
{
    float width = self.view.bounds.size.width;
    float height = self.view.bounds.size.height;
    
    NSArray *midiNums = [self getCurrentScale];
    NSArray *colors = @[[UIColor redColor], [UIColor yellowColor], [UIColor greenColor]];
    
    for (int i = 0; i < 3; i++){
        int **coords = septagon_coordinates((i + 1) * (int)height / 8, (int)width / 2, (int)height / 2);
        for (int j = 0; j < 7; j++){
            float x = coords[0][j];
            float y = coords[1][j];
            INTInstrumentNote *note = [[INTInstrumentNote alloc] initWithFrame:CGRectMake(x, y, 65.0, 65.0)
                                                                       noteNum:[midiNums[j] integerValue]
                                                                    noteOctave:i + 4
                                                                         color:colors[i]];
            note.center = CGPointMake(x, y);
            
            [self.view addSubview:note];
            [self.notes addObject:note];
        }
    }
    self.initializing = NO;
}

- (void)addNote
{
    INTInstrumentNote *note = [[INTInstrumentNote alloc] initWithFrame:CGRectMake(10.0, 300.0, 65.0, 65.0)
                                                               noteNum:self.currentNote
                                                            noteOctave:self.currentOctave
                                                                 color:[UIColor greenColor]];
    note.center = CGPointMake(10.0, 350.0);
    note.layer.cornerRadius = note.frame.size.width / 2;
    note.layer.borderColor = [UIColor blackColor].CGColor;
    note.layer.borderWidth = 2;
    
    [self.view addSubview:note];
    [self.notes addObject:note];
}

- (void)deleteNote
{
    NSInteger count = self.selectedNotes.count;
    
    for (NSInteger i = count - 1; i >= 0; i--){

        INTInstrumentNote * note = (INTInstrumentNote *)self.selectedNotes[i];
        [self.selectedNotes removeObject:note];
        [self.notes removeObject:note];
        
        [note removeFromSuperview];
    }
}

- (void)dragNote:(INTInstrumentNote *)note
           touch:(UITouch *)touch
{
    CGPoint prevTouchPoint = [self.previousTouch locationInView:self.view];
    CGPoint currTouchPoint = [touch locationInView:self.view];
    
    DDLogVerbose(@"%@ %@", NSStringFromCGPoint(prevTouchPoint), NSStringFromCGPoint(currTouchPoint));
    
    [note setCenter:currTouchPoint];
}

- (INTInstrumentNote *)getIntersectsForTouch:(UITouch *)touch
                                    inEvent:(UIEvent *)event
                                  forNotes:(NSMutableArray *)notes
{
    CGPoint touchLocation = [touch locationInView:self.view];
    CGRect touchRect = CGRectMake(touchLocation.x, touchLocation.y, 1, 1);
    
    for (int i = 0; i < [notes count]; i++) {
        INTInstrumentNote *note = (INTInstrumentNote *)[notes objectAtIndex:i];
        CGRect noteRect = note.frame;

        if (CGRectIntersectsRect(touchRect, noteRect)){
            return note;
        }
    }
    return nil;
}

- (NSArray *)getNonintersectsForTouch:(UITouch *)touch
                              inEvent:(UIEvent *)event
                             forNotes:(NSMutableArray *)notes
{
    NSMutableArray *nonIntersects = [[NSMutableArray alloc] init];
    
    CGPoint touchLocation = [touch locationInView:self.view];
    CGRect touchRect = CGRectMake(touchLocation.x, touchLocation.y, 1, 1);
    
    int numTouches = [event.allTouches count];
    CGRect *touchRects = malloc(sizeof(CGRect) * numTouches);
    int numRects = 0;
    
    for (UITouch *touch in event.allTouches){
        CGPoint location = [touch locationInView:self.view];
        CGRect otherTouchRect = CGRectMake(location.x, location.y, 1, 1);
        
        touchRects[numRects] = otherTouchRect;
        numRects++;
    }

    for (int i = 0; i < [notes count]; i++){
        BOOL shouldAdd = YES;
        
        INTInstrumentNote *note = (INTInstrumentNote *)[notes objectAtIndex:i];
        CGRect noteRect = note.frame;
        
        for (int j = 0; j < numRects; j++){
            if (CGRectIntersectsRect(noteRect, touchRects[j]) || CGRectIntersectsRect(noteRect, touchRect)){
                shouldAdd = NO;
            }
        }
        
        if (shouldAdd){
            [nonIntersects addObject:note];
        }
        
    }
    return nonIntersects;
}

- (void)playNote:(INTInstrumentNote *)note
{
    NSString *playnote = [NSString stringWithFormat:@"%d-note", self.dollarZero];

    if (note.playing){
        note.playing = NO;
        NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInteger:[note getScaledMidiNum]],
                         [NSNumber numberWithInteger:0], nil];
        [PdBase sendList:data toReceiver:playnote];
        
        [self.playingNotes removeObject:note];
        [note.layer removeAllAnimations];
    } else {
        note.playing = YES;
        NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInteger:[note getScaledMidiNum]],
                         [NSNumber numberWithInteger:50], nil];
        
        [PdBase sendList:data toReceiver:playnote];
        [self.playingNotes addObject:note];
        
        CABasicAnimation *animation;
        
        animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration=0.3;
        animation.repeatCount=HUGE_VALF;
        animation.autoreverses=NO;
        animation.fromValue=[NSNumber numberWithFloat:1.0];
        animation.toValue=[NSNumber numberWithFloat:0.3];
        [note.layer addAnimation:animation forKey:@"animatePlaying"];
    }
    note.touched = YES;
}

- (void)killNote:(INTInstrumentNote *)note
{
    note.playing = NO;
    NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInteger:[note getScaledMidiNum]],
                     [NSNumber numberWithInteger:0], nil];
    NSString *playnote = [NSString stringWithFormat:@"%d-note", self.dollarZero];
    [PdBase sendList:data toReceiver:playnote];
    
    [self.playingNotes removeObject:note];
    [note.layer removeAllAnimations];
}

- (void)selectNote:(INTInstrumentNote *)note
{
    if (note.selected){
        note.selected = NO;
        [self.selectedNotes removeObject:note];
        [note.layer removeAllAnimations];

    } else {
        note.selected = YES;
        [self.selectedNotes addObject:note];
        [(INTRootViewController *)self.parentViewController setLabelsNeedUpdate];
        [note.layer removeAllAnimations];
        
        CABasicAnimation *animation;
        animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration=0.2;
        animation.repeatCount=HUGE_VALF;
        animation.autoreverses=YES;
        animation.fromValue=[NSNumber numberWithFloat:1.0];
        animation.toValue=[NSNumber numberWithFloat:0.6];
        [note.layer addAnimation:animation forKey:@"animateSelection"];
        
        self.currentNote = note;
        self.currentMidiNote = note.midiNum;
        self.currentOctave = note.octave;
        [(INTRootViewController *)self.parentViewController setLabelsNeedUpdate];
    }
    note.touched = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    DDLogVerbose(@"Started");
    UITouch *touch = [touches anyObject];

    INTInstrumentNote *tappedNote = [self getIntersectsForTouch:touch
                                                        inEvent:event
                                                       forNotes:self.notes];
    
    CGRect noteRect = tappedNote.frame;
    
    if (tappedNote){
        if (self.editFlag){
            [self selectNote:tappedNote];
            self.touchStartedOnNote = YES;
        } else {
            [self playNote: tappedNote];
        }
    }
    
    self.previousTouch = touch;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    DDLogVerbose(@"Moved");
    UITouch *touch = [touches anyObject];
    
    INTInstrumentNote *tappedNote = [self getIntersectsForTouch:touch
                                                        inEvent:event
                                                       forNotes:self.notes];
    CGRect noteRect = tappedNote.frame;
    
    if (self.editFlag){
        if (tappedNote && !tappedNote.touched){
            [self selectNote:tappedNote];
        } else if (tappedNote && self.touchStartedOnNote){
            [self dragNote:tappedNote touch:touch];
        }
    } else {
        if (tappedNote && !tappedNote.touched){
            [self playNote: tappedNote];
        }
        NSArray *notesToKill = [self getNonintersectsForTouch:touch
                                                      inEvent:event
                                                     forNotes:self.playingNotes];
        
        for (int i = 0; i < [notesToKill count]; i++){
            INTInstrumentNote *note = (INTInstrumentNote *)[notesToKill objectAtIndex:i];
            if (!note.hold){
                [self killNote:note];
            }
            note.touched = NO;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    DDLogVerbose(@"ended");
    UITouch *touch = [touches anyObject];
    
    INTInstrumentNote *tappedNote = [self getIntersectsForTouch:touch
                                                        inEvent:event
                                                       forNotes:self.notes];
    NSArray *notesToToggle = [self getNonintersectsForTouch:touch
                                                    inEvent:event
                                                   forNotes:self.notes];
    if (tappedNote && !tappedNote.hold){
        if (!self.editFlag && !tappedNote.hold){
            [self killNote: tappedNote];
        }
        tappedNote.touched = NO;
    }
    
    for (int i = 0; i < [notesToToggle count]; i++){
        INTInstrumentNote *note = (INTInstrumentNote *)[notesToToggle objectAtIndex:i];

        if (!self.editFlag && !note.hold){
            [self killNote:note];
        }
        note.touched = NO;
    }
    
    self.touchStartedOnNote = NO;
    self.previousTouch = nil;
}

- (void)incrementNote
{
    if (self.currentMidiNote < 11){
        self.currentMidiNote++;
    } else{
        self.currentMidiNote = 0;
    }
}

- (void)decrementNote
{
    if (self.currentMidiNote > 0){
        self.currentMidiNote--;
    } else {
        self.currentMidiNote = 11;
    }
}

- (BOOL)incrementOctave
{
    if (self.currentOctave < 8){
        self.currentOctave++;
        return YES;
    }
    return NO;
}

- (BOOL)decrementOctave
{
    if (self.currentOctave > 1){
        self.currentOctave--;
        return YES;
    }
    return NO;
}

- (void)reset
{
    for (INTInstrumentNote *note in self.notes){
        [note removeFromSuperview];
    }
    
    self.notes = nil;
    self.notes = [[NSMutableArray alloc] init];
    
    self.playingNotes = nil;
    self.playingNotes = [[NSMutableArray alloc] init];
    
    self.selectedNotes = nil;
    self.selectedNotes = [[NSMutableArray alloc] init];
    
    [self initNotes];
    
}

- (NSArray *)getCurrentScale
{
    if([self.currentScale  isEqual: @"C"]){
        return @[@0,@2,@4,@5,@7,@9,@11];
    } else if ([self.currentScale  isEqual: @"C#"]){
        return @[@1,@3,@5,@6,@8,@10,@0];
    } else if ([self.currentScale  isEqual: @"D"]){
        return @[@2,@4,@6,@7,@9,@11,@1];
    } else if ([self.currentScale  isEqual: @"D#"]){
        return @[@3,@5,@7,@8,@10,@0,@2];
    } else if ([self.currentScale  isEqual: @"E"]){
        return @[@4,@6,@8,@9,@11,@1,@3];
    } else if ([self.currentScale  isEqual: @"F"]){
        return @[@5,@7,@9,@10,@0,@2,@4];
    } else if ([self.currentScale  isEqual: @"F#"]){
        return @[@6,@8,@10,@11,@1,@3,@5];
    } else if ([self.currentScale  isEqual: @"G"]){
        return @[@7,@9,@11,@0,@2,@4,@6];
    } else if ([self.currentScale  isEqual: @"G#"]){
        return @[@8,@10,@0,@1,@3,@5,@7];
    } else if ([self.currentScale  isEqual: @"A"]){
        return @[@9,@11,@1,@2,@4,@6,@8];
    } else if ([self.currentScale  isEqual: @"A#"]){
        return @[@10,@0,@2,@3,@5,@7,@9];
    } else if ([self.currentScale  isEqual: @"B"]){
        return @[@11,@1,@3,@4,@6,@8,@10];
    } else{
        return @[];
    }
}

- (void)updateEditFlag:(int)editFlag
{
    self.editFlag = editFlag;
}

//
//#pragma mark - Navigation
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//}


@end
