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
    self.currentNote = 0;
    self.currentOctave = 5;
    self.currentNoteIndex = -1;
    self.currentScale = @"C";
    self.notes = [[NSMutableArray alloc] init];
    self.playingNotes = [[NSMutableArray alloc] init];
    self.selectedNotes = [[NSMutableArray alloc] init];
    
    DDLogVerbose(@"Instrument View finished loading");
}

// Cannot do this in viewWillLoad as bounds are not set properly at that time
- (void)viewWillLayoutSubviews
{
    if ([self.notes count] == 0){
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
            note.layer.cornerRadius = note.frame.size.width / 2;
            note.layer.borderColor = [UIColor blackColor].CGColor;
            note.layer.borderWidth = 2;
            
            [self.view addSubview:note];
            [self.notes addObject:note];
        }
    }
    
    for (int i = 0; i < [self.notes count]; i++){
        UIPanGestureRecognizer *pgRec = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(panNote:)];
        [self.notes[i] addGestureRecognizer:pgRec];
    }
}

- (void)addNote
{
    INTInstrumentNote *note = [[INTInstrumentNote alloc] initWithFrame:CGRectMake(10.0, 300.0, 65.0, 65.0)
                                                               noteNum:self.currentNote
                                                            noteOctave:self.currentOctave
                                                                 color:[UIColor greenColor]];
    note.center = CGPointMake(10.0, 300.0);
    note.layer.cornerRadius = note.frame.size.width / 2;
    note.layer.borderColor = [UIColor blackColor].CGColor;
    note.layer.borderWidth = 2;
    
    UIPanGestureRecognizer *pgRec = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(panNote:)];
    
    [note addGestureRecognizer:pgRec];
    
    [self.view addSubview:note];
    [self.notes addObject:note];
}

- (void)deleteNote
{
    if (self.currentNoteIndex != -1){
        INTInstrumentNote * note = [self.notes objectAtIndex:self.currentNoteIndex];
        [self.notes removeObjectAtIndex:self.currentNoteIndex];
        [note removeFromSuperview];
        self.currentNoteIndex = -1;
    }
}

- (void)killNote:(INTInstrumentNote *)note
{
    if (self.editFlag){
        self.currentNoteIndex = [self.notes indexOfObject:note];
        self.currentNote = note.midiNum;
        self.currentOctave = note.octave;
        [(INTRootViewController *)self.parentViewController setLabelsNeedUpdate];
    } else {
        NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInteger:[note getScaledMidiNum]],
                         [NSNumber numberWithInteger:0], nil];
        
        NSString *playnote = [NSString stringWithFormat:@"%d-note", self.dollarZero];
        [PdBase sendList:data toReceiver:playnote];
        note.playing = NO;
        [self.playingNotes removeObject:note];
        [note.layer removeAllAnimations];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Started");
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    CGRect touchRect = CGRectMake(location.x, location.y, 1, 1);

    if (self.editFlag){
        [self editNote:touchRect];
    } else {
        [self playNote:touchRect];
    }
}

- (void)editNote:(CGRect)location
{
    for (int i = 0; i < [self.notes count]; i++){
        INTInstrumentNote *note = (INTInstrumentNote *)self.notes[i];
        CGRect noteRect = note.frame;
        
        if (CGRectIntersectsRect(location, noteRect)){
            [self selectNote:note];
        }
    }
}

- (void)selectNote: (INTInstrumentNote *)note
{
    if (note.selected){
        note.selected = NO;
        [self.selectedNotes removeObject:note];
        [(INTRootViewController *)self.parentViewController setLabelsNeedUpdate];

        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             note.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){
                         }];
    } else{
        note.selected = YES;
        [self.selectedNotes addObject:note];
        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut |
         UIViewAnimationOptionRepeat |
         UIViewAnimationOptionAutoreverse |
         UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             note.alpha = 0.0f;
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

- (void)playNote:(CGRect)location
{
    for (int i = 0; i < [self.playingNotes count]; i++){
        INTInstrumentNote *note = (INTInstrumentNote *)self.playingNotes[i];
        CGRect noteRect = note.frame;
        
        if (!CGRectIntersectsRect(location, noteRect) && note.hold == NO){
            [self toggleNote:note];
        }
    }
    
    for (int i = 0; i < [self.notes count]; i++){
        INTInstrumentNote *note = (INTInstrumentNote *)self.notes[i];
        CGRect noteRect = note.frame;
        
        if (CGRectIntersectsRect(location, noteRect) && !note.wasToggled){
            [self toggleNote:note];
        }
    }
}

- (void)toggleNote:(INTInstrumentNote *)note
{
    if (note.playing){
        note.playing = NO;
        NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInteger:[note getScaledMidiNum]],
                         [NSNumber numberWithInteger:0], nil];
        
        NSString *playnote = [NSString stringWithFormat:@"%d-note", self.dollarZero];
        [PdBase sendList:data toReceiver:playnote];
        [self.playingNotes removeObject:note];
        [note.layer removeAllAnimations];
        note.wasToggled = NO;

    } else {
        note.playing = YES;
        NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInteger:[note getScaledMidiNum]],
                         [NSNumber numberWithInteger:50], nil];
        
        NSString *playnote = [NSString stringWithFormat:@"%d-note", self.dollarZero];
        [PdBase sendList:data toReceiver:playnote];
        [self.playingNotes addObject:note];
        
        CABasicAnimation *theAnimation;
        
        theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        theAnimation.duration=0.3;
        theAnimation.repeatCount=HUGE_VALF;
        theAnimation.autoreverses=NO;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        theAnimation.toValue=[NSNumber numberWithFloat:0.3];
        [note.layer addAnimation:theAnimation forKey:@"animateOpacity"];
        note.wasToggled = YES;

    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Moved");
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    CGRect touchRect = CGRectMake(location.x, location.y, 1, 1);
    
    if (self.editFlag){
        [self editNote:touchRect];
    } else {
        [self playNote:touchRect];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Cancelled");

    for (int i = 0; i < [self.playingNotes count]; i++){
        INTInstrumentNote *note = (INTInstrumentNote *)self.playingNotes[i];
        
        if (!note.hold){
            [self toggleNote:note];
        }
    }
    
//    for (int i = 0; i < [self.notes count]; i++){
//        INTInstrumentNote *note = (INTInstrumentNote *)self.notes[i];
//        note.wasToggled = NO;
//    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    DDLogVerbose(@"ended");
    
    for (int i = 0; i < [self.playingNotes count]; i++){
        INTInstrumentNote *note = (INTInstrumentNote *)self.playingNotes[i];
        
        if (!note.hold){
            [self toggleNote:note];
        }
    }
 
    for (int i = 0; i < [self.notes count]; i++){
        INTInstrumentNote *note = (INTInstrumentNote *)self.notes[i];
        note.wasToggled = NO;
    }
}

- (void)incrementNote
{
    if (self.currentNote < 11){
        self.currentNote++;
    } else{
        self.currentNote = 0;
    }
}

- (void)decrementNote
{
    if (self.currentNote > 0){
        self.currentNote--;
    } else {
        self.currentNote = 11;
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

- (IBAction)toggleMode:(id)sender
{
    if (self.editFlag){
        self.editFlag = 0;
    }
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

- (void)panNote:(UIPanGestureRecognizer *)gestureRecognizer
{
    DDLogVerbose(@"Panning");
    if (!self.editFlag){
        NSUInteger numTouches = [gestureRecognizer numberOfTouches];
        
        if (numTouches > 0){
            CGPoint location = [gestureRecognizer locationOfTouch:0 inView:self.view];
            CGRect touchRect = CGRectMake(location.x, location.y, 1, 1);
            [self playNote:touchRect];
        }
        return;
    }

    INTInstrumentNote *note = (INTInstrumentNote *)[gestureRecognizer view];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[note superview]];
        
        [note setCenter:CGPointMake([note center].x + translation.x, [note center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[note superview]];
    }
}

//
//#pragma mark - Navigation
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//}


@end
