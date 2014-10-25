//
//  INTInstrumentViewController.m
//  Hackathon2014
//
//  Created by Connor Taylor on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTInstrumentViewController.h"
#import "INTRootViewController.h"
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
    self.currentScale = @"C";
    self.notes = [[NSMutableArray alloc] init];
    self.playingNotes = [[NSMutableArray alloc] init];
    
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
            INTInstrumentNote *note = [[INTInstrumentNote alloc] initWithFrame:CGRectMake(x, y, 70.0, 70.0)
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

- (void)initTrashBin
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    float x = self.view.bounds.origin.x + self.view.bounds.size.width -  74.0;
    float y = self.view.bounds.origin.y + self.view.bounds.size.height;

    DDLogVerbose(@"%f %f", x, y);
    
    [path moveToPoint:CGPointMake(x, y)];
    [path addLineToPoint:CGPointMake(x, y - 74.0)];
    [path addLineToPoint:CGPointMake(x + 74.0, y - 74.0)];
    [path addLineToPoint:CGPointMake(x + 74.0, y)];
    [path addLineToPoint:CGPointMake(x, y)];

    [path stroke];
    [path closePath];
}

- (void)addNote
{
    INTInstrumentNote *note = [[INTInstrumentNote alloc] initWithFrame:CGRectMake(10.0, 300.0, 70.0, 70.0)
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

- (void)playNote:(INTInstrumentNote *)note
{
    if (self.editFlag){
        self.currentNote = note.midiNum;
        self.currentOctave = note.octave;
        [(INTRootViewController *)self.parentViewController setLabelsNeedUpdate];
    } else if (!note.playing){
        NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInteger:[note getScaledMidiNum]],
                         [NSNumber numberWithInteger:50], nil];
        
        NSString *playnote = [NSString stringWithFormat:@"%d-note", self.dollarZero];
        [PdBase sendList:data toReceiver:playnote];
        note.playing = YES;
        
        CABasicAnimation *theAnimation;
        
        theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        theAnimation.duration=0.3;
        theAnimation.repeatCount=HUGE_VALF;
        theAnimation.autoreverses=NO;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        theAnimation.toValue=[NSNumber numberWithFloat:0.3];
        [note.layer addAnimation:theAnimation forKey:@"animateOpacity"];
    }
}

- (void)killNote:(INTInstrumentNote *)note
{
    if (self.editFlag){
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
    
    [self updateNotes:location];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Moved");
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    [self updateNotes:location];
}

- (void)updateNotes:(CGPoint)location
{
    CGRect touchRect = CGRectMake(location.x, location.y, 1, 1);
    
    for (int i = 0; i < [self.playingNotes count]; i++){
        INTInstrumentNote *note = (INTInstrumentNote *)self.playingNotes[i];
        CGRect noteRect = note.frame;
        
        if (!CGRectIntersectsRect(touchRect, noteRect)){
            [self killNote:note];
        }
    }
    
    for (int i = 0; i < [self.notes count]; i++){
        INTInstrumentNote *note = (INTInstrumentNote *)self.notes[i];
        CGRect noteRect = note.frame;
        
        if (CGRectIntersectsRect(touchRect, noteRect)){
            [self playNote:note];
            [self.playingNotes addObject:note];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    DDLogVerbose(@"ended");
    for (int i = 0; i < [self.playingNotes count]; i++){
        [self killNote:(INTInstrumentNote *)self.playingNotes[i]];
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

/**
 Scale and rotation transforms are applied relative to the layer's anchor point this method moves a gesture recognizer's view's anchor point between the user's fingers.
 */
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        INTInstrumentNote *note = (INTInstrumentNote *)gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:note];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:note.superview];
        
        note.layer.anchorPoint = CGPointMake(locationInView.x / note.bounds.size.width, locationInView.y / note.bounds.size.height);
        note.center = locationInSuperview;
    }
}


- (void)panNote:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (self.editFlag != 1){
        NSUInteger numTouches = [gestureRecognizer numberOfTouches];
        if (numTouches > 0){
            [self updateNotes:[gestureRecognizer locationOfTouch:0 inView:self.view]];
        }
        return;
    }

    INTInstrumentNote *note = (INTInstrumentNote *)[gestureRecognizer view];
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[note superview]];
        
        [note setCenter:CGPointMake([note center].x + translation.x, [note center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[note superview]];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
