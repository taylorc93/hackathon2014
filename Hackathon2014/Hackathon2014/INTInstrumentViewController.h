//
//  INTInstrumentViewController.h
//  Hackathon2014
//
//  Created by Connor Taylor on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INTInstrumentNote.h"

@interface INTInstrumentViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *currentScale;
@property (nonatomic, strong) NSMutableArray *notes;
@property (nonatomic, strong) NSMutableArray *selectedNotes;

@property int dollarZero;
@property (nonatomic, weak) INTInstrumentNote *currentNote;

@property int currentMidiNote;
@property int currentOctave;
@property int editFlag;
@property int numChannels;

- (void)updateEditFlag:(int)editFlag;

- (BOOL)incrementOctave;
- (BOOL)decrementOctave;

- (void)incrementNote;
- (void)decrementNote;

- (void)addNote;
- (void)deleteNote;

- (void)reset;

@end
