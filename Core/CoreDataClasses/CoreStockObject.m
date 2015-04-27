//
//  CoreStockObject.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/21/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "CoreStockObject.h"


@implementation CoreStockObject

@dynamic tickerSymbol;
@dynamic companyName;
@dynamic quantityOwned;
@dynamic totalPaid;
@dynamic annualPerformance;
@dynamic dailyPerformance;
@dynamic isOnWatchList;
@dynamic isFakeStock;
@dynamic dateUpdated;

+(instancetype)fetchWithContext:(NSManagedObjectContext *)managedObjectContext predicateFormat:(NSString *)predicateFormat
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tickerSymbol" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    if(predicateFormat || ![predicateFormat isEqualToString:@""]) {
        [request setPredicate:[NSPredicate predicateWithFormat:predicateFormat]];
    }
    NSArray *object = [managedObjectContext executeFetchRequest:request error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return nil;
    }
    if(object.count==0) return nil;
    return object[0];
}

+(instancetype)newWithContext:(NSManagedObjectContext *)managedObjectContext
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:managedObjectContext];
}

+(NSArray *)allObjectsWithContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tickerSymbol" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"isFakeStock == NO"]];
    NSArray *object = [managedObjectContext executeFetchRequest:request error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return nil;
    }
    if(object.count==0) return nil;
    return object;
}

+(NSArray *)allFakeObjectsWithContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tickerSymbol" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"isFakeStock == YES"]];
    NSArray *object = [managedObjectContext executeFetchRequest:request error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return nil;
    }
    if(object.count==0) return nil;
    return object;
}

+(NSArray *)fetchPurchasedWithContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tickerSymbol" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(quantityOwned > 0) AND (isFakeStock == NO)"]];
    NSArray *object = [managedObjectContext executeFetchRequest:request error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return nil;
    }
    if(object.count==0) return nil;
    return object;
}

+(NSArray *)fetchFakePurchasedWithContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tickerSymbol" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(quantityOwned > 0) AND (isFakeStock == YES)"]];
    NSArray *object = [managedObjectContext executeFetchRequest:request error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return nil;
    }
    if(object.count==0) return nil;
    return object;
}

@end
