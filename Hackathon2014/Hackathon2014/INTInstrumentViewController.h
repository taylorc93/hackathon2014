//
//  INTInstrumentViewController.h
//  Hackathon2014
//
//  Created by Connor Taylor & Chris Penny on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#import "INTInstrumentNote.h"
#import "PdBase.h"

@interface INTInstrumentViewController : UIViewController <PdListener>

@property (nonatomic, strong) NSString *currentScale;
@property (nonatomic, strong) NSMutableArray *notes;
@property (nonatomic, strong) NSMutableArray *selectedNotes;
@property (nonatomic, weak) INTInstrumentNote *currentNote;

@property int dollarZero;

@property int currentMidiNote;
@property int currentOctave;
@property int editFlag;
@property int numChannels;

- (void)receiveBangFromSource:(NSString *)source;

- (void)updateEditFlag:(int)editFlag;
- (void)selectNote:(INTInstrumentNote *)note;

- (BOOL)incrementOctave;
- (BOOL)decrementOctave;

- (void)incrementNote;
- (void)decrementNote;

- (void)addNote;
- (void)deleteNote;

- (void)reset;

@end
