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
/*
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
*/
-(NSArray *)getStockObjects
{
    return [CoreStockObject allObjectsWithContext:_managedObjectContext];
}


-(void)saveRealStockJSON:(NSData *)jsonData
{
    NSError *error;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return;
    }
    for(NSDictionary *tempDict in jsonArray) {
        CoreStockObject *stockObj = [CoreStockObject newWithContext:_managedObjectContext];
        stockObj.companyName = [[tempDict valueForKey:@"name"] stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
        stockObj.tickerSymbol = [[tempDict valueForKey:@"symbol"] stringByRemovingPercentEncoding];
        stockObj.isFakeStock = [NSNumber numberWithBool:NO];
    }
    [self save];
}

-(RealStock *)buyStock:(RealStock *)stock withQuantity:(int)quantity
{
    CoreStockObject *purchasedStock = [CoreStockObject fetchWithContext:_managedObjectContext predicateFormat:[NSString stringWithFormat:@"tickerSymbol = '%@'",stock.tickerSymbol]];
    purchasedStock.totalPaid = [NSNumber numberWithDouble:([purchasedStock.totalPaid doubleValue]+[stock.currentValue  doubleValue])];
    purchasedStock.quantityOwned = [NSNumber numberWithInt:[purchasedStock.quantityOwned intValue] + quantity];
    [self save];
    stock.quantityOwned = purchasedStock.quantityOwned;
    stock.totalSpent = purchasedStock.totalPaid;
    return stock;
}

-(RealStock *)sellStock:(RealStock *)stock withQuantity:(int)quantity
{
    CoreStockObject *purchasedStock = [CoreStockObject fetchWithContext:_managedObjectContext predicateFormat:[NSString stringWithFormat:@"tickerSymbol = '%@'",stock.tickerSymbol]];
    double bottom = (double)[purchasedStock.quantityOwned intValue];
    double top = bottom - (double)quantity;
    double percent = top/bottom;
    NSNumber *newAmtPaid = [NSNumber numberWithDouble:([purchasedStock.totalPaid doubleValue]*percent)];
    purchasedStock.totalPaid = newAmtPaid;
    purchasedStock.quantityOwned = [NSNumber numberWithInt:[purchasedStock.quantityOwned intValue] - quantity];
    [self save];
    stock.quantityOwned = purchasedStock.quantityOwned;
    stock.totalSpent = purchasedStock.totalPaid;
    return stock;
}

-(NSArray *)getOwnedStocksWithDelegate:(id<RealStockDelegate>)realStockDelegate
{
    
    NSMutableArray *purchasedStocks = [[CoreStockObject fetchPurchasedWithContext:_managedObjectContext] mutableCopy];
    for(int i=0; i<purchasedStocks.count; i++) {
        RealStock *stock = [RealStock stockWithCoreStockObject:purchasedStocks[i] andDelegate:realStockDelegate];
        purchasedStocks[i] = stock;
        [stock downloadCurrentData];
    }
    return purchasedStocks;
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
