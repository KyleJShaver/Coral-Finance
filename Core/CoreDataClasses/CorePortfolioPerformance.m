//
//  CorePortfolioPerformance.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/21/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "CorePortfolioPerformance.h"


@implementation CorePortfolioPerformance

@dynamic isFakeStock;
@dynamic dateUpdated;
@dynamic amountReturn;
@dynamic amountSpent;
@dynamic amountBalance;

+(instancetype)objWithContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error;
    NSArray *object = [managedObjectContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])] error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return nil;
    }
    if(object.count==0) return nil;
    return nil;
}

@end
