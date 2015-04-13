//
//  FakeStock.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/4/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RealStock.h"

@interface FakeStock : RealStock

@property (strong, nonatomic) NSString *seed;

@end
