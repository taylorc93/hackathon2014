//
//  INTInstrumentViewController.h
//  Hackathon2014
//
//  Created by Connor Taylor on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "INTInstrumentNote.h"

@interface INTInstrumentViewController : UIViewController

@property (nonatomic, strong) NSString *currentScale;
@property (nonatomic, strong) NSMutableArray *notes;

@property int dollarZero;
@property int currentNote;
@property int currentOctave;
@property int editFlag;

- (void)updateEditFlag:(int)editFlag;
- (BOOL)incrementOctave;
- (BOOL)decrementOctave;
- (void)incrementNote;
- (void)decrementNote;
- (void)addNote;

@end
