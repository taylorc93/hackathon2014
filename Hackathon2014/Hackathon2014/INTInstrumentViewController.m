//
//  INTInstrumentViewController.m
//  Hackathon2014
//
//  Created by Connor Taylor & Chris Penny on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTRootViewController.h"
#import "INTInstrumentViewController.h"
#import "INTInstrumentNote.h"
#include "septagon_coordinates.h"
#include "penis_coordinates.h"
#import "PdDispatcher.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface INTInstrumentViewController ()

@property (nonatomic, strong) NSMutableArray *playingNotes;
@property BOOL initializing;
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
    self.numChannels = 0;
    
    PdDispatcher *dispatcher = [[PdDispatcher alloc] init];
    [PdBase setDelegate:dispatcher];
    [dispatcher addListener:self forSource:@"config-ready"];
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

    for (int i = 0; i < 4; i++){
        float radius = (i + 1) * (int)height / 8;
//        int **coords = septagon_coordinates(radius / 1.12, (int)width / 2, (int)height / 2);
        int **coords = penis_coordinates(i);
        
        for (int j = 0; j < 7; j++){
            DDLogVerbose(@"Midinum: %@", midiNums[j]);
            float x = coords[0][j];
            float y = coords[1][j];
            
            _numChannels++;
            
            [self initNoteWithFrame:CGRectMake(x, y, 65.0, 65.0)
                            midiNum:[midiNums[[self circleOfFifths:(j + (i*4))]] integerValue]
                             octave:i + 3
                          channelId:self.numChannels
                                  x:x
                                  y:y];
            [self createPdNote];
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
                                                             channelId:channelId
                                                              parentVC:self];
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
        [self.playingNotes removeObject:note];
    } else {
        [self.playingNotes addObject:note];
    }
    [note toggle];
    note.touched = YES;
}

- (void)killNote:(INTInstrumentNote *)note
{
    note.playing = NO;
    [note stop];
    
    [self.playingNotes removeObject:note];
}

- (void)selectNote:(INTInstrumentNote *)note
{
    if (note.selected){
        [self.selectedNotes removeObject:note];
    } else {
        [self.selectedNotes addObject:note];
        self.currentNote = note;
        self.currentMidiNote = note.midiNum;
        self.currentOctave = note.octave;
//        [(INTRootViewController *)self.parentViewController setLabelsNeedUpdate];
    }
    [note select];
    note.touched = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    INTInstrumentNote *tappedNote = [self getIntersectsForTouch:touch
                                                        inEvent:event
                                                       forNotes:self.notes];
    CGRect noteRect = tappedNote.frame;
    NSArray *untappedNotes = [self getNonintersectsForTouch:touch
                                                  inEvent:event
                                                 forNotes:self.notes];

    if (tappedNote && !tappedNote.touched){
        if (self.editFlag){
            [self selectNote:tappedNote];
        } else {
            [self playNote: tappedNote];
        }
    }
            
    for (int i = 0; i < [untappedNotes count]; i++){
        INTInstrumentNote *note = (INTInstrumentNote *)[untappedNotes objectAtIndex:i];
        if (!self.editFlag && !note.hold){
            [self killNote:note];
        }
        note.touched = NO;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.editFlag){
        for (INTInstrumentNote *note in self.notes){
            if (!note.hold){
                [self killNote:note];
            }
            note.touched = NO;
        }
    }
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

- (int)circleOfFifths:(int)position
{
    // Inverted Circle of Fifths, but chords with First Inversion:
    return (position * 4) % 7;

    // Normal Circle of Fifths, but chords with Second Inversion
//    return (7 - ((position * 4) % 7) ) % 7;
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

//- (void)receiveBangFromSource:(NSString *)source
//{
//    DDLogVerbose(@"Received PD Message, adding new note");
//    if (self.initializedPDNotes < _numChannels){
//        [PdBase sendBangToReceiver:@"add_note"];
//    }
//    self.initializedPDNotes++;
//}

- (void)createPdNote
{
    [PdBase sendBangToReceiver:@"add_note"];
}


@end
