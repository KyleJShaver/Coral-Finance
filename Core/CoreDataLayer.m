//
//  CoreDataLayer.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/17/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "CoreDataLayer.h"

@implementation CoreDataLayer

@synthesize managedObjectContext = _managedObjectContext;

-(id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    _managedObjectContext = context;
    return self;
}

-(NSArray *)getRealStockJSON
{
    NSError *error;
    RealStocks *realStocks = [self realStocks];
    if(!realStocks) return nil;
    NSArray *retVal = [NSJSONSerialization JSONObjectWithData:[realStocks.rawJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return nil;
    }
    return retVal;
}

-(NSArray *)getStockObjects
{
    RealStocks *realStocks = [self realStocks];
    if(!realStocks) return nil;
    NSArray *realStockObjects = [realStocks.stocks allObjects];
    return realStockObjects;
}

-(RealStocks *)realStocks
{
    NSError *error;
    NSArray *results = [_managedObjectContext executeFetchRequest:[NSFetchRequest fetchRequestWithEntityName:@"RealStocks"] error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return nil;
    }
    if(results.count==0) return nil;
    RealStocks *realStocks = results[0];
    return realStocks;
}

-(void)saveRealStockJSON:(NSData *)jsonData
{
    NSError *error;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    RealStocks *realStocks = (RealStocks *)[NSEntityDescription insertNewObjectForEntityForName:@"RealStocks" inManagedObjectContext:_managedObjectContext];
    realStocks.rawJSON = jsonString;
    for(NSDictionary *tempDict in jsonArray) {
        RealStockObject *stock = [NSEntityDescription insertNewObjectForEntityForName:@"RealStockObject" inManagedObjectContext:_managedObjectContext];
        stock.companyName = [tempDict valueForKey:@"name"];
        stock.tickerSymbol = [tempDict valueForKey:@"symbol"];
        [realStocks addStocks:[NSSet setWithObject:stock]];
    }
    [self save];
}

-(void)save
{
    NSError *error;
    [_managedObjectContext save:&error];
    if(error) NSLog(@"%@",error.description);
}

@end
