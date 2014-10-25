//
//  INTInstrumentNote.h
//  Hackathon2014
//
//  Created by Connor Taylor on 10/24/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INTInstrumentNote : UIView

- (instancetype)initWithFrame:(CGRect)frame
                      noteNum:(int)midiNum
                   noteOctave:(int)octave
                        color:(UIColor *)color;

- (int)getScaledMidiNum;

@property (nonatomic, strong) UIColor *color;
@property int midiNum;
@property int octave;
@property BOOL playing;
@property (nonatomic, strong) NSString *noteName;

@end
