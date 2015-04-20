//
//  RealStock.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/4/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PriceTime.h"
#import "RealStockObject.h"

@class RealStock;

@protocol RealStockDelegate <NSObject>

@required

-(void)realStockDidDownloadRequestedInformation:(RealStock *)realStock;
-(void)realStockDidDownloadYearInformation:(RealStock *)realStock;
-(void)realStockDidDownloadCurrentInformation:(RealStock *)realStock;
-(void)realStockDoneDownloading:(RealStock *)realStock;
-(void)realStockError:(NSError *)error downloadingInformation:(RealStock *)realStock;

@end

@interface RealStock : NSObject

typedef NS_ENUM(NSUInteger, PerformanceWindow) {
    PerformanceWindowOneDay,
    PerformanceWindowOneMonth,
    PerformanceWindowThreeMonth,
    PerformanceWindowSixMonth,
    PerformanceWindowOneYear,
    PerformanceWindowTwoYear,
};

@property (strong, nonatomic) id<RealStockDelegate> delegate;
@property (strong, nonatomic) NSString *companyName;
@property (strong, nonatomic) NSString *tickerSymbol;
@property (strong, nonatomic) NSNumber *currentValue;
@property (strong, nonatomic) NSNumber *currentHigh;
@property (strong, nonatomic) NSNumber *currentLow;
@property (strong, nonatomic) NSNumber *openingValue;
@property (strong, nonatomic) NSNumber *marketCap;
@property (strong, nonatomic) NSNumber *yearHigh;
@property (strong, nonatomic) NSNumber *yearLow;
@property (strong, nonatomic) NSArray *performanceValues;
@property (strong, nonatomic) NSNumber *quantityOwned;
@property (strong, nonatomic) NSNumber *totalSpent;
@property PerformanceWindow performanceWindow;

-(id)initWithDelegate:(id<RealStockDelegate>)delegate;
-(id)initWithTicker:(NSString *)tickerSymbol andDelegate:(id<RealStockDelegate>)delegate;
-(id)initWithTicker:(NSString *)tickerSymbol performanceWindow:(PerformanceWindow)performanceWindow andDelegate:(id<RealStockDelegate>)delegate;
+(instancetype) stockWithCDObject:(RealStockObject *)realStockObject andDelegate:(id<RealStockDelegate>)delegate;
-(void)downloadStockData;
-(void)downloadCurrentData;
-(NSString *)dailyPerformancePercent;
-(NSString *)overallPerformancePercent;
- (NSComparisonResult)compareSymbols:(RealStock *)otherObject;

@end
