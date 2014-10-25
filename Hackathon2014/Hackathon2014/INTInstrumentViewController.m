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
    
    float width = self.view.bounds.size.width;
    float height = self.view.bounds.size.height;
    
    DDLogVerbose(@"%@", NSStringFromCGPoint(self.view.center));
    
    float xVals[] = {574, 490, 422, 422, 490, 574, 612};
    float yVals[] = {306, 287, 341, 427, 481, 462, 384};
    int midiNums[] = {64, 65, 66, 67, 68, 69, 70};
    
    self.notes = [[NSMutableArray alloc] init];
    for (int i = 0; i < 7; i++){
        INTInstrumentNote *note = [[INTInstrumentNote alloc] initWithFrame:CGRectMake(xVals[i], yVals[i], 60.0, 60.0)
                                                                   noteNum:midiNums[i]
                                                                     color:[UIColor greenColor]];
        note.center = CGPointMake(xVals[i], yVals[i]);
        
        note.layer.cornerRadius = note.frame.size.width / 2;
        note.layer.borderColor = [UIColor blackColor].CGColor;
        note.layer.borderWidth = 2;
        
        note.backgroundColor = note.color;
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
