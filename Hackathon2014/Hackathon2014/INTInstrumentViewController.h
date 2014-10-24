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

@property (nonatomic, strong) IBOutletCollection(INTInstrumentNote) NSArray *notes;

@end
