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

-(NSArray *)getStockObjects
{
    return [CoreStockObject allObjectsWithContext:_managedObjectContext];
}

-(NSArray *)getFakeStockObjects
{
    return [CoreStockObject allFakeObjectsWithContext:_managedObjectContext];
}

-(BOOL)isInFakeStockMode
{
    CoreSettings *settings = [CoreSettings fetchWithContext:_managedObjectContext];
    if(!settings) {
        settings = [CoreSettings newWithContext:_managedObjectContext];
        settings.isModeFakeStocks = [NSNumber numberWithBool:NO];
        settings.dateUpdated = [NSDate date];
        [self save];
        return NO;
    }
    BOOL retVal = [settings.isModeFakeStocks boolValue];
    return retVal;
}

-(BOOL)setIsInFakeStockMode:(BOOL)isInFakeStockMode
{
    CoreSettings *settings = [CoreSettings fetchWithContext:_managedObjectContext];
    if(!settings) {
        settings = [CoreSettings newWithContext:_managedObjectContext];
        settings.isModeFakeStocks = [NSNumber numberWithBool:isInFakeStockMode];
        settings.dateUpdated = [NSDate date];
        [self save];
        return isInFakeStockMode;
    }
    settings.isModeFakeStocks = [NSNumber numberWithBool:isInFakeStockMode];
    [self save];
    return isInFakeStockMode;
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

-(void)saveFakeStockJSON:(NSData *)jsonData
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
        stockObj.isFakeStock = [NSNumber numberWithBool:YES];
    }
    [self save];
}

-(RealStock *)buyStock:(RealStock *)stock withQuantity:(int)quantity
{
    CoreStockObject *purchasedStock = [CoreStockObject fetchWithContext:_managedObjectContext predicateFormat:[NSString stringWithFormat:@"tickerSymbol = '%@'",stock.tickerSymbol]];
    CorePortfolioPerformance *performance;
    if(stock.isFakeStock) performance = [CorePortfolioPerformance fakeObjectWithContext:_managedObjectContext];
    else performance = [CorePortfolioPerformance realObjectWithContext:_managedObjectContext];
    if(!performance) {
        performance = [CorePortfolioPerformance newWithContext:_managedObjectContext];
        if(stock.isFakeStock) performance.isFakeStock = [NSNumber numberWithBool:YES];
        else performance.isFakeStock = [NSNumber numberWithBool:NO];
    }
    double portfolioSpent = [performance.amountSpent doubleValue];
    double portfolioBalance = [performance.amountBalance doubleValue];
    portfolioBalance -= ([stock.currentValue  doubleValue] * (double)quantity);
    if(portfolioBalance<=0) {
        portfolioSpent += (-1.0*portfolioBalance);
        portfolioBalance = 0.0;
    }
    performance.amountSpent = [NSNumber numberWithDouble:portfolioSpent];
    performance.amountBalance = [NSNumber numberWithDouble:portfolioBalance];
    purchasedStock.totalPaid = [NSNumber numberWithDouble:[purchasedStock.totalPaid doubleValue]+[stock.currentValue  doubleValue]];
    purchasedStock.quantityOwned = [NSNumber numberWithInt:[purchasedStock.quantityOwned intValue] + quantity];
    [self save];
    stock.quantityOwned = purchasedStock.quantityOwned;
    stock.totalSpent = purchasedStock.totalPaid;
    return stock;
}

-(RealStock *)sellStock:(RealStock *)stock withQuantity:(int)quantity
{
    CoreStockObject *purchasedStock = [CoreStockObject fetchWithContext:_managedObjectContext predicateFormat:[NSString stringWithFormat:@"tickerSymbol = '%@'",stock.tickerSymbol]];
    CorePortfolioPerformance *performance;
    if(stock.isFakeStock) performance = [CorePortfolioPerformance fakeObjectWithContext:_managedObjectContext];
    else performance = [CorePortfolioPerformance realObjectWithContext:_managedObjectContext];
    if(!performance) {
        performance = [CorePortfolioPerformance newWithContext:_managedObjectContext];
        if(stock.isFakeStock) performance.isFakeStock = [NSNumber numberWithBool:YES];
        else performance.isFakeStock = [NSNumber numberWithBool:NO];
    }
    double portfolioBalance = [performance.amountBalance doubleValue];
    double transactionAmount = ([stock.currentValue  doubleValue] * (double)quantity);
    portfolioBalance += transactionAmount;
    performance.amountBalance = [NSNumber numberWithDouble:portfolioBalance];
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

-(NSArray *)getOwnedFakeStocksWithDelegate:(id<RealStockDelegate>)realStockDelegate
{
    NSMutableArray *purchasedStocks = [[CoreStockObject fetchFakePurchasedWithContext:_managedObjectContext] mutableCopy];
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

-(NSArray *)portfolioPerformanceWithDelegate:(id<RealStockDelegate>)delegate
{
    NSMutableArray *retVal = [NSMutableArray array];
    RealStock *performanceStock = [[RealStock alloc] init];
    RealStock *worstPerformer;
    RealStock *bestPerformer;
    NSArray *ownedStocks;
    performanceStock.tickerSymbol = @"Performance";
    performanceStock.isFakeStock = self.isInFakeStockMode;
    if(self.isInFakeStockMode) {
        performanceStock.companyName = @"Coral-Created Stocks";
        ownedStocks = [self getOwnedFakeStocksWithDelegate:delegate];
    }
    else {
        performanceStock.companyName = @"Real Stocks";
        ownedStocks = [self getOwnedStocksWithDelegate:delegate];
    }
    int stocksOwned = 0;
    for(RealStock *stock in ownedStocks) {
        stocksOwned+=[stock.quantityOwned intValue];
    }
    performanceStock.quantityOwned = [NSNumber numberWithInt:stocksOwned];
    [retVal addObject:performanceStock];
    return retVal;
}

-(void)save
{
    NSError *error;
    [_managedObjectContext save:&error];
    if(error) NSLog(@"%@",error.description);
}

@end
