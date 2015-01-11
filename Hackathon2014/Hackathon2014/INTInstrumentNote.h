//
//  INTInstrumentNote.h
//  Hackathon2014
//
//  Created by Connor Taylor & Chris Penny on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INTInstrumentNote : UIView

- (instancetype)initWithFrame:(CGRect)frame
                      noteNum:(int)midiNum
                   noteOctave:(int)octave
                    channelId:(int)channelId
                     parentVC:(UIViewController *)parentVC;

- (int)getScaledMidiNum;
- (void)toggle;
- (void)play;
- (void)stop;
- (void)select;
- (void)bendPitch:(float)bendNum;

@property (nonatomic, strong) UIColor *color;
@property int midiNum;
@property int octave;
@property (nonatomic, weak) UIViewController *parentVC;

@property BOOL playing;
@property BOOL selected;
@property BOOL hold;
@property BOOL touched; //Prevents a swipe from continuously toggling and untoggling

@property int channelId;

@property (nonatomic, strong) NSString *noteName;

@end
