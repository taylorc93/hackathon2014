//
//  INTSlider.m
//  Hackathon2014
//
//  Created by Connor Taylor & Chris Penny on 11/7/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTSlider.h"
#import "PdBase.h"

@implementation INTSlider{
    float currentWidth;
    float scaleFactor;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){

        CGRect fillerFrame = CGRectMake(0.0, 0.0, self.frame.size.width / 2, self.frame.size.height);
        self.filler = [[UIView alloc] initWithFrame:fillerFrame];
        self.filler.backgroundColor = [UIColor colorWithRed:255.0 / 255.0 green:237.0 / 255.0 blue:79.0 / 255.0 alpha:1.0];
        
        self.filler.layer.cornerRadius = self.frame.size.height / 2;
        self.layer.cornerRadius = self.frame.size.height / 2;
        
        [self addSubview:self.filler];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    [self updateFill:touchLocation];
    if([self.receiver  isEqual: @"all"]) {
        [self updateRelease:touchLocation];
    }
    else {
        [self updateValue:touchLocation];    
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    [self updateFill:touchLocation];
    if( [self.receiver  isEqual: @"all"] ) {
        [self updateRelease:touchLocation];
    }
    else {
        [self updateValue:touchLocation];
    }
}

- (void)updateFill:(CGPoint)touchLocation
{
    float newWidth = touchLocation.x - self.filler.frame.origin.x;
    
    if (newWidth > self.frame.size.width){
        newWidth = self.frame.size.width;
    } else if (newWidth < 0){
        newWidth = 0;
    }
    
    self.filler.frame = CGRectMake(0.0, 0.0, newWidth, self.frame.size.height);
    currentWidth = newWidth;
}

- (void)updateValue:(CGPoint)touchLocation
{
    float scaleFactor = currentWidth / self.frame.size.width;
    if( [self.receiver isEqual:@"autodelay"] || [self.receiver isEqual:@"tremolo_depth"] || [self.receiver isEqual:@"ringmod_depth"] ) {
        self.value = scaleFactor;
    } else if ( [self.receiver isEqual:@"chorus_depth"] ) {
        self.value = scaleFactor * 2;
    }
    else {
        self.value = scaleFactor * currentWidth;
    }
    
    [PdBase sendFloat:self.value toReceiver:self.receiver];
}

- (void)updateRelease:(CGPoint)touchLocation
{
    float scaleFactor = ((currentWidth / self.frame.size.width) * 66 + (2.0/3.0)) * 2;
    self.value = scaleFactor * currentWidth;
    NSNumber *releaseValue = [NSNumber numberWithFloat:(self.value)];
    
    NSString *messageToSend = [NSString stringWithFormat:@"release"];
    [PdBase sendMessage:messageToSend withArguments:[NSArray arrayWithObjects:releaseValue, nil] toReceiver:self.receiver];
}

@end
