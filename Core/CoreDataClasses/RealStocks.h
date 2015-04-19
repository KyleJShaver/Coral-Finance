//
//  RealStocks.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/17/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface RealStocks : NSManagedObject

@property (nonatomic, retain) NSString * rawJSON;
@property (nonatomic, retain) NSDate * dateUpdated;
@property (nonatomic, retain) NSManagedObject *watchList;
@property (nonatomic, retain) NSSet *stocks;
@end

@interface RealStocks (CoreDataGeneratedAccessors)

- (void)addStocksObject:(NSManagedObject *)value;
- (void)removeStocksObject:(NSManagedObject *)value;
- (void)addStocks:(NSSet *)values;
- (void)removeStocks:(NSSet *)values;

@end
