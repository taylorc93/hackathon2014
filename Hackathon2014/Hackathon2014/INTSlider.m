//
//  INTSlider.m
//  Hackathon2014
//
//  Created by Connor Taylor on 11/7/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import "INTSlider.h"
#import "PdBase.h"

@implementation INTSlider{
    float currentWidth;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){

        CGRect fillerFrame = CGRectMake(0.0, 0.0, self.frame.size.width / 2, self.frame.size.height);
        self.backgroundColor = [UIColor colorWithRed:22.0 / 255.0 green:118.0 / 255.0 blue:134.0 / 255.0 alpha:1.0];
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
    [self updateValue:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    [self updateFill:touchLocation];
    [self updateValue:touchLocation];
}

- (void)updateValue:(CGPoint)touchLocation
{
    float scaleFactor = currentWidth / self.frame.size.width;
    self.value = scaleFactor * self.maxValue;
    
//    [PdBase sendFloat:self.value toReceiver:self.receiver];
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

@end
