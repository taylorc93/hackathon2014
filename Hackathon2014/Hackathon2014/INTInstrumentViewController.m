//
//  INTInstrumentViewController.m
//  Hackathon2014
//
//  Created by Connor Taylor on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTRootViewController.h"
#import "INTInstrumentViewController.h"
#include "septagon_coordinates.h"
#import "PdDispatcher.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface INTInstrumentViewController ()

@property (nonatomic, strong) NSMutableArray *playingNotes;
@property (nonatomic, strong) UITouch *previousTouch;
@property BOOL touchStartedOnNote;
@property BOOL initializing;
@property float initialTouchX;
@property float initialTouchY;
@property int initializedPDNotes;

@end

@implementation INTInstrumentViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    void *patch = [PdBase openFile:@"Master.pd"
                              path: [[NSBundle mainBundle] resourcePath]];
    if (!patch){
        DDLogError(@"Couldn't open patch");
    }
    
    self.initializedPDNotes = 0;
    self.dollarZero = [PdBase dollarZeroForFile:patch];
    self.currentNote = nil;
    self.currentMidiNote = 0;
    self.currentOctave = 5;
    self.currentScale = @"C";
    self.notes = [[NSMutableArray alloc] init];
    self.playingNotes = [[NSMutableArray alloc] init];
    self.selectedNotes = [[NSMutableArray alloc] init];
    self.initializing = YES;
    self.touchStartedOnNote = NO;
    self.numChannels = 0;
    
    PdDispatcher *dispatcher = [[PdDispatcher alloc] init];
    [PdBase setDelegate:dispatcher];
    [dispatcher addListener:self forSource:@"config-ready"];
}

// Cannot do this in viewWillLoad as bounds are not set properly at that time
- (void)viewWillLayoutSubviews
{
    if ([self.notes count] == 0 && self.initializing){
        [self initNotes:0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)createNotes:(id)sender
{
    [self initNotes:1];
}

- (void)initNotes:(int)i
{
    float width = self.view.bounds.size.width;
    float height = self.view.bounds.size.height;
    
    [self createPdNote];
    
    NSArray *midiNums = [self getCurrentScale];
    DDLogVerbose(@"%@", midiNums);

    for (int i = 0; i < 3; i++){
        int **coords = septagon_coordinates((i + 1) * (int)height / 8, (int)width / 2, (int)height / 2);
        
        for (int j = 0; j < 7; j++){
            DDLogVerbose(@"Midinum: %@", midiNums[j]);
            float x = coords[0][j];
            float y = coords[1][j];
            
            [self initNoteWithFrame:CGRectMake(x, y, 65.0, 65.0)
                            midiNum:[midiNums[j] integerValue]
                             octave:i + 4
                          channelId:_numChannels + 1
                                  x:x
                                  y:y];
            _numChannels++;
        }
    }
    self.initializing = NO;
}

- (void)initNoteWithFrame:(CGRect)frame
                  midiNum:(NSInteger)midiNum
                   octave:(int)octave
                channelId:(int)channelId
                        x:(float)x
                        y:(float)y
{
    INTInstrumentNote *note = [[INTInstrumentNote alloc] initWithFrame:CGRectMake(x, y, 65.0, 65.0)
                                                               noteNum:midiNum
                                                            noteOctave:octave
                                                             channelId:channelId];
    note.center = CGPointMake(x, y);
    [self.view addSubview:note];
    [self.notes addObject:note];
}

- (void)addNote
{
//    INTInstrumentNote *note = [[INTInstrumentNote alloc] initWithFrame:CGRectMake(50.0, 325.0, 65.0, 65.0)
//                                                               noteNum:self.currentMidiNote
//                                                            noteOctave:self.currentOctave];
//    note.center = CGPointMake(50.0, 325.0);
//    
//    [self.view addSubview:note];
//    [self.notes addObject:note];
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
    [UIView animateWithDuration:0.1 animations:^{
        [note setCenter:currTouchPoint];
    }];
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

// Gets all notes that do not intersect with the given touch.
// Takes into account other touches on the screen and does NOT
// return a note if it is being held by another touch
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
        DDLogVerbose(@"stopping");
        note.playing = NO;
        [note stop];
        
        [self.playingNotes removeObject:note];
        [note.layer removeAllAnimations];
    } else {
        DDLogVerbose(@"playing");
        note.playing = YES;
        [note play];
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
    [note stop];
    
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

- (void)bendNote:(INTInstrumentNote*)note
       touch:(UITouch *)touch
{
    CGPoint noteCenter = note.center;
    CGPoint touchPoint = [touch locationInView:self.view];
    
    DDLogVerbose(@"inital: %f touch: %f", self.initialTouchY, touchPoint.y);
    
    float yDiff = (self.initialTouchY - touchPoint.y) / 4;
    float pitchBend = yDiff + 64;
    
    if (pitchBend > 127.0){
        pitchBend = 127.0;
    } else if (pitchBend < 0.0){
        pitchBend = 0.0;
    }
    
    [note bendPitch:pitchBend];
    
    NSString *receiver = [NSString stringWithFormat:@"%d-pitchbend", self.dollarZero];
    [PdBase sendFloat:pitchBend toReceiver:receiver];
    
    DDLogVerbose(@"%f", pitchBend);
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
        } else {
            [self playNote: tappedNote];
        }
        self.touchStartedOnNote = YES;
        
        CGPoint touchLocation = [touch locationInView:self.view];
        self.initialTouchX = touchLocation.x;
        self.initialTouchY = touchLocation.y;
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
        if (!self.touchStartedOnNote){
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
        } else if (self.touchStartedOnNote){
            [self bendNote:tappedNote touch:touch];
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
    if (tappedNote){
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
//    NSString *receiver = [NSString stringWithFormat:@"%d-pitchbend", self.dollarZero];
//    [PdBase sendFloat:64.0 toReceiver:receiver];
    
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
    if (self.currentOctave < 7){
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
    
//    [self initNotes];
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
    if (self.editFlag){
        for (INTInstrumentNote *note in self.selectedNotes){
            [note.layer removeAllAnimations];
            note.selected = NO;
        }
        self.selectedNotes = nil;
    } else {
        self.selectedNotes = [[NSMutableArray alloc] init];
    }
    
    self.editFlag = editFlag;
}

- (void)receiveBangFromSource:(NSString *)source
{
    DDLogVerbose(@"%@", source);
    DDLogVerbose(@"Received PD Message, adding new note");
    if (self.initializedPDNotes < _numChannels){
        [PdBase sendBangToReceiver:@"add_note"];
    }
    self.initializedPDNotes++;
}

- (void)createPdNote
{
    [PdBase sendBangToReceiver:@"add_note"];
}

//
//#pragma mark - Navigation
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//}


@end
