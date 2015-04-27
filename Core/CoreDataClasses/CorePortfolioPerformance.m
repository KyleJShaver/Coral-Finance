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

+(instancetype)newWithContext:(NSManagedObjectContext *)managedObjectContext
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:managedObjectContext];
}

+(CorePortfolioPerformance *)realObjectWithContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    [request setPredicate:[NSPredicate predicateWithFormat:@"isFakeStock == NO"]];
    NSArray *object = [managedObjectContext executeFetchRequest:request error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return nil;
    }
    if(object.count==0) return nil;
    return object[0];
}

+(CorePortfolioPerformance *)fakeObjectWithContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    [request setPredicate:[NSPredicate predicateWithFormat:@"isFakeStock == YES"]];
    NSArray *object = [managedObjectContext executeFetchRequest:request error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return nil;
    }
    if(object.count==0) return nil;
    return object[0];
}

@end
