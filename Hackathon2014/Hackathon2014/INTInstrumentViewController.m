//
//  INTInstrumentViewController.m
//  Hackathon2014
//
//  Created by Connor Taylor on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTInstrumentViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface INTInstrumentViewController ()

@end

@implementation INTInstrumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DDLogVerbose(@"Instrument View Loaded");
    
    self.currentNote = 0;
    self.currentOctave = 5;
    
    float xVals[] = {574, 490, 422, 422, 490, 574, 612};
    float yVals[] = {306, 287, 341, 427, 481, 462, 384};
    int midiNums[] = {60, 62, 64, 65, 67, 69, 71};
    
    self.notes = [[NSMutableArray alloc] init];
    for (int i = 0; i < 7; i++){
        INTInstrumentNote *note = [[INTInstrumentNote alloc] initWithFrame:CGRectMake(xVals[i], yVals[i], 60.0, 60.0)
                                                                   noteNum:midiNums[i]
                                                                     color:[UIColor greenColor]];
        note.center = CGPointMake(xVals[i], yVals[i]);
        
        note.layer.cornerRadius = note.frame.size.width / 2;
        note.layer.borderColor = [UIColor blackColor].CGColor;
        note.layer.borderWidth = 2;
        
        [self.view addSubview:note];
        [self.notes addObject:note];
    }
    
    for (int i = 0; i < [self.notes count]; i++){
        UIPanGestureRecognizer *pgRec = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(panNote:)];
        [self.notes[i] addGestureRecognizer:pgRec];
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
