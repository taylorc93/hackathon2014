//
//  INTInstrumentViewController.m
//  Hackathon2014
//
//  Created by Connor Taylor on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTInstrumentViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "PdBase.h"
#include "septagon_coordinates.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface INTInstrumentViewController ()

@end

@implementation INTInstrumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DDLogVerbose(@"Instrument View Loaded");

    void *patch = [PdBase openFile:@"Main.pd"
                              path: [[NSBundle mainBundle] resourcePath]];
    if (!patch){
        DDLogError(@"Couldn't open patch");
    }
    
    self.dollarZero = [PdBase dollarZeroForFile:patch];
    self.currentNote = 0;
    self.currentOctave = 5;
    
    float xVals[] = {574, 490, 422, 422, 490, 574, 612};
    float yVals[] = {306, 287, 341, 427, 481, 462, 384};
    int midiNums[] = {60, 62, 64, 65, 67, 69, 71};
    NSArray *colors = @[[UIColor redColor], [UIColor yellowColor], [UIColor greenColor]];
    
    self.notes = [[NSMutableArray alloc] init];
    for (int i = 0; i < 3; i++){
        int **coords = septagon_coordinates(75 * (i + 1), 512, 384);
        for (int j = 0; j < 7; j++){
            float x = coords[0][j];
            float y = coords[1][j];
            INTInstrumentNote *note = [[INTInstrumentNote alloc] initWithFrame:CGRectMake(x, y, 60.0, 60.0)
                                                                       noteNum:midiNums[j]
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
        
        UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(playNote:)];
        [self.notes[i] addGestureRecognizer:tapRec];
    }
    [self.view.window makeKeyAndVisible];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)addNote:(id)sender
{
    int noteNum = self.currentNote + 12 * self.currentOctave;
    
    INTInstrumentNote *note = [[INTInstrumentNote alloc] initWithFrame:CGRectMake(10.0, 300.0, 60.0, 60.0)
                                                               noteNum:noteNum
                                                                 color:[UIColor greenColor]];
    note.layer.cornerRadius = note.frame.size.width / 2;
    note.layer.borderColor = [UIColor blackColor].CGColor;
    note.layer.borderWidth = 2;
    
    UIPanGestureRecognizer *pgRec = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(panNote:)];
    [note addGestureRecognizer:pgRec];
    
    [self.view addSubview:note];
    [self.notes addObject:note];
}

- (void)playNote:(UITapGestureRecognizer*)gestureRecognizer
{
    DDLogDebug(@"OK");
    INTInstrumentNote *note = gestureRecognizer.view;
    
    NSArray *data = [NSArray arrayWithObjects:[NSNumber numberWithInteger:note.midiNum],
                                                [NSNumber numberWithInteger:250], nil];
    
    NSString *receiver = [NSString stringWithFormat:@"%d-makenote", self.dollarZero];
    [PdBase sendList:data toReceiver:receiver];
}

- (IBAction)incrementNote:(id)sender
{
    if (self.currentNote < 11){
        self.currentNote++;
    } else{
        self.currentNote = 0;
    }
    
    NSString *labelText = [NSString stringWithFormat:@"Current Note: %@", [self getNoteName:self.currentNote]];
    self.noteLabel.text = labelText;
}

- (IBAction)decrementNote:(id)sender
{
    if (self.currentNote > 0){
        self.currentNote--;
    } else {
        self.currentNote = 11;
    }
    
    NSString *labelText = [NSString stringWithFormat:@"Current Note: %@", [self getNoteName:self.currentNote]];
    self.noteLabel.text = labelText;
}

- (IBAction)incrementOctave:(id)sender
{
    if (self.currentOctave < 8){
        self.currentOctave++;
        self.octaveLabel.text = [NSString stringWithFormat:@"Current Octave: %d", self.currentOctave];
    }
}

- (IBAction)decrementOctave:(id)sender
{
    if (self.currentOctave > 1){
        self.currentOctave--;
        self.octaveLabel.text = [NSString stringWithFormat:@"Current Octave: %d", self.currentOctave];
    }
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
            DDLogInfo(@"Incompatible Midi Num");
            return @"";
    }
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
