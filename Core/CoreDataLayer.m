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

-(void)buyStock:(RealStock *)stock withQuantity:(int)quantity
{
    RealStockObject *purchasedStock = [NSEntityDescription insertNewObjectForEntityForName:@"RealStockObject" inManagedObjectContext:_managedObjectContext];
    purchasedStock.companyName = stock.companyName;
    purchasedStock.tickerSymbol = stock.tickerSymbol;
    PurchasedRealStockObject *purchasedStockContainer = [NSEntityDescription insertNewObjectForEntityForName:@"PurchasedRealStockObject" inManagedObjectContext:_managedObjectContext];
    purchasedStockContainer.purchaseDate = [NSDate date];
    double amountPaid = [stock.currentValue doubleValue] * (double)quantity;
    purchasedStockContainer.purchasePrice = [NSNumber numberWithDouble:amountPaid];
    purchasedStockContainer.quantityPurchased = [NSNumber numberWithInt:quantity];
    purchasedStockContainer.stock = purchasedStock;
    OwnedRealStockList *ownedList = [self ownedRealStockList];
    [ownedList addStocks:[NSSet setWithObject:purchasedStockContainer]];
    [self save];
}

-(void)sellStock:(RealStock *)stock withQuantity:(int)quantity
{
    RealStockObject *purchasedStock = [NSEntityDescription insertNewObjectForEntityForName:@"RealStockObject" inManagedObjectContext:_managedObjectContext];
    purchasedStock.companyName = stock.companyName;
    purchasedStock.tickerSymbol = stock.tickerSymbol;
    PurchasedRealStockObject *purchasedStockContainer = [NSEntityDescription insertNewObjectForEntityForName:@"PurchasedRealStockObject" inManagedObjectContext:_managedObjectContext];
    purchasedStockContainer.purchaseDate = [NSDate date];
    double amountPaid = [stock.currentValue doubleValue] * (double)quantity;
    purchasedStockContainer.purchasePrice = [NSNumber numberWithDouble:amountPaid];
    purchasedStockContainer.quantityPurchased = [NSNumber numberWithInt:quantity];
    purchasedStockContainer.stock = purchasedStock;
    OwnedRealStockList *ownedList = [self ownedRealStockList];
    [ownedList addStocks:[NSSet setWithObject:purchasedStockContainer]];
    [self save];
}

-(OwnedRealStockList *)ownedRealStockList
{
    RealStocks *realStocks = [self realStocks];
    OwnedRealStockList *ownedList = realStocks.ownedStocks;
    if(!ownedList) {
        ownedList = [NSEntityDescription insertNewObjectForEntityForName:@"OwnedRealStockList" inManagedObjectContext:_managedObjectContext];
        realStocks.ownedStocks = ownedList;
        [self save];
        return ownedList;
    }
    else return ownedList;
}

-(NSArray *)getOwnedStocksWithDelegate:(id<RealStockDelegate>)realStockDelegate
{
    OwnedRealStockList *ownedList = [self ownedRealStockList];
    if(ownedList.stocks.count==0) {
        return nil;
    }
    else {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(PurchasedRealStockObject *purchasedStock in ownedList.stocks) {
            BOOL exists = NO;
            int qty = [purchasedStock.quantityPurchased intValue];
            double pricePaid = [purchasedStock.purchasePrice doubleValue];
            NSString *ticker = purchasedStock.stock.tickerSymbol;
            for(RealStock *realStock in array) {
                if([realStock.tickerSymbol isEqualToString:ticker]) {
                    exists = YES;
                    realStock.quantityOwned = [NSNumber numberWithInt:[realStock.quantityOwned intValue]+qty];
                    realStock.totalSpent = [NSNumber numberWithDouble:[realStock.totalSpent doubleValue]+pricePaid];
                };
            }
            if(!exists) {
                RealStock *realStock = [RealStock stockWithCDObject:purchasedStock.stock andDelegate:realStockDelegate];
                realStock.quantityOwned = [NSNumber numberWithInt:qty];
                realStock.totalSpent = [NSNumber numberWithDouble:pricePaid];
                [array addObject:realStock];
            }
        }
        for(int i=(int)array.count-1; i>=0; i--) {
            RealStock *stock = array[i];
            if([stock.quantityOwned intValue]<=0)
                [array removeObjectAtIndex:i];
        }
        return array;
    };
}

-(NSArray *)getOwnedStockWithStock:(RealStock *)realStock andDelegate:(id<RealStockDelegate>)delegate
{
    NSArray *ownedStocks = [self getOwnedStocksWithDelegate:delegate];
    for(RealStock *temp in ownedStocks) {
        if([realStock.tickerSymbol isEqualToString:temp.tickerSymbol]) {
            return @[temp];
        }
    }
    return nil;
}

-(void)save
{
    NSError *error;
    [_managedObjectContext save:&error];
    if(error) NSLog(@"%@",error.description);
}

@end
