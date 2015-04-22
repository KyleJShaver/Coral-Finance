//
//  CoreStockObject.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/21/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreStockObject : NSManagedObject

@property (nonatomic, retain) NSString * tickerSymbol;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSNumber * quantityOwned;
@property (nonatomic, retain) NSNumber * totalPaid;
@property (nonatomic, retain) NSString * annualPerformance;
@property (nonatomic, retain) NSString * dailyPerformance;
@property (nonatomic, retain) NSNumber * isOnWatchList;
@property (nonatomic, retain) NSNumber * isFakeStock;
@property (nonatomic, retain) NSDate * dateUpdated;

+(instancetype)fetchWithContext:(NSManagedObjectContext *)managedObjectContext predicateFormat:(NSString *)predicateFormat;
+(instancetype)newWithContext:(NSManagedObjectContext *)managedObjectContext;
+(NSArray *)allObjectsWithContext:(NSManagedObjectContext *)managedObjectContext;
+(NSArray *)allFakeObjectsWithContext:(NSManagedObjectContext *)managedObjectContext;
+(NSArray *)fetchPurchasedWithContext:(NSManagedObjectContext *)managedObjectContext;

@end
