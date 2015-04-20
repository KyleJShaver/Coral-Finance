//
//  RealStocks.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/19/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OwnedRealStockList, RealStockObject, RealStockWatchList;

@interface RealStocks : NSManagedObject

@property (nonatomic, retain) NSDate * dateUpdated;
@property (nonatomic, retain) NSString * rawJSON;
@property (nonatomic, retain) NSSet *stocks;
@property (nonatomic, retain) RealStockWatchList *watchList;
@property (nonatomic, retain) OwnedRealStockList *ownedStocks;
@end

@interface RealStocks (CoreDataGeneratedAccessors)

- (void)addStocksObject:(RealStockObject *)value;
- (void)removeStocksObject:(RealStockObject *)value;
- (void)addStocks:(NSSet *)values;
- (void)removeStocks:(NSSet *)values;

@end
