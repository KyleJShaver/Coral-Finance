//
//  CoreDataLayer.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/17/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RealStock.h"
#import "CorePortfolioPerformance.h"
#import "CoreSettings.h"
#import "CoreStockObject.h"

@interface CoreDataLayer : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(id)initWithContext:(NSManagedObjectContext *)context;
-(BOOL)isInFakeStockMode;
-(BOOL)setIsInFakeStockMode:(BOOL)isInFakeStockMode;
-(NSArray *)getStockObjects;
-(NSArray *)getFakeStockObjects;
-(void)saveRealStockJSON:(NSData *)jsonData;
-(void)saveFakeStockJSON:(NSData *)jsonData;
-(RealStock *)buyStock:(RealStock *)stock withQuantity:(int)quantity;
-(RealStock *)sellStock:(RealStock *)stock withQuantity:(int)quantity;
-(NSArray *)getOwnedStocksWithDelegate:(id<RealStockDelegate>)realStockDelegate;
-(NSArray *)getOwnedFakeStocksWithDelegate:(id<RealStockDelegate>)realStockDelegate;
-(NSArray *)getOwnedStockWithStock:(RealStock *)realStock andDelegate:(id<RealStockDelegate>)delegate;
-(NSArray *)portfolioPerformanceWithDelegate:(id<RealStockDelegate>)delegate;

@end
