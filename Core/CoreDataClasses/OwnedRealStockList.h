//
//  OwnedRealStockList.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/19/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface OwnedRealStockList : NSManagedObject

@property (nonatomic, retain) NSSet *stocks;
@end

@interface OwnedRealStockList (CoreDataGeneratedAccessors)

- (void)addStocksObject:(NSManagedObject *)value;
- (void)removeStocksObject:(NSManagedObject *)value;
- (void)addStocks:(NSSet *)values;
- (void)removeStocks:(NSSet *)values;

@end
