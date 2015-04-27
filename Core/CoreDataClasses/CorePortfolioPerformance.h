//
//  CorePortfolioPerformance.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/21/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CorePortfolioPerformance : NSManagedObject

@property (nonatomic, retain) NSNumber * isFakeStock;
@property (nonatomic, retain) NSDate * dateUpdated;
@property (nonatomic, retain) NSNumber * amountReturn;
@property (nonatomic, retain) NSNumber * amountSpent;
@property (nonatomic, retain) NSNumber * amountBalance;

+(instancetype)newWithContext:(NSManagedObjectContext *)managedObjectContext;
+(CorePortfolioPerformance *)realObjectWithContext:(NSManagedObjectContext *)managedObjectContext;
+(CorePortfolioPerformance *)fakeObjectWithContext:(NSManagedObjectContext *)managedObjectContext;

@end
