//
//  RealStockObject.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/17/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RealStockObject : NSManagedObject

@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * tickerSymbol;

@end
