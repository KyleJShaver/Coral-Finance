//
//  RealStockWatchList.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/17/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RealStockObject;

@interface RealStockWatchList : NSManagedObject

@property (nonatomic, retain) NSSet *stocks;
@end

@interface RealStockWatchList (CoreDataGeneratedAccessors)

- (void)addStocksObject:(RealStockObject *)value;
- (void)removeStocksObject:(RealStockObject *)value;
- (void)addStocks:(NSSet *)values;
- (void)removeStocks:(NSSet *)values;

@end
