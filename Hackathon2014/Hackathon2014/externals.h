//
//  externals.h
//  Hackathon2014
//
//  Created by Chris Penny on 1/21/15.
//  Copyright (c) 2015 Intrinsic Audio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdAudioController.h"
#import "PdDispatcher.h"

extern void dollarg_setup(void);
extern void counter_setup(void);

@interface externals : NSObject

+(void)setup;

@end