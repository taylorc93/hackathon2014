//
//  INTSlider.h
//  Hackathon2014
//
//  Created by Connor Taylor & Chris Penny on 11/7/14.
//  Copyright (c) 2014 Intrinsic Audio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INTSlider : UIView

// View that covers the filled portion of the slider
@property (nonatomic, strong) UIView *filler;

@property (nonatomic, strong) NSString *receiver;
@property float value;

@property int dollarZero;

@end
