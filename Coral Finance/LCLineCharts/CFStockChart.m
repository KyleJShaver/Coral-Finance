//
//  CFStockChart.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/9/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "CFStockChart.h"
#import "RealStock.h"

@implementation CFStockChart

-(id)initWithStock:(RealStock *)stock
{
    self = [super init];
    if(stock==nil) return nil;
    self.stock = stock;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"yyyyMMMd" options:0 locale:[NSLocale currentLocale]]];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"hh:mm" options:0 locale:[NSLocale currentLocale]]];
    [timeFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    LCLineChartData *data = ({
        LCLineChartData *subdata = [LCLineChartData new];
        subdata.title = self.stock.tickerSymbol;
        subdata.color = [Globals positiveColor];
        double stepper = ((double)self.stock.performanceValues.count)/40.0;
        if(stepper<1 || self.stock.performanceWindow != PerformanceWindowOneDay) stepper = 1.0;
        NSMutableArray *arr = [NSMutableArray array];
        BOOL lastIncluded = NO;
        for(NSUInteger i = 0; i < self.stock.performanceValues.count; i+=(int)stepper) {
            [arr addObject:[((PriceTime *)self.stock.performanceValues[i]) timeAsDate]];
            if(i==self.stock.performanceValues.count-1) lastIncluded = YES;
        };
        NSMutableArray *arr2 = [NSMutableArray array];
        for(NSUInteger i = 0; i < self.stock.performanceValues.count; i+=(int)stepper) {
            [arr2 addObject:@([((PriceTime *)self.stock.performanceValues[i]).price doubleValue])];
        }
        if(!lastIncluded) {
            [arr addObject:[((PriceTime *)self.stock.performanceValues.lastObject) timeAsDate]];
            [arr2 addObject:@([((PriceTime *)self.stock.performanceValues.lastObject).price doubleValue])];
        }
        subdata.itemCount = arr.count;
        subdata.xMin = -2;
        subdata.xMax = subdata.itemCount+1;
        subdata.getData = ^(NSUInteger item) {
            float x = item;
            float y = [arr2[item] floatValue];
            NSString *label1;
            if(self.stock.performanceWindow != PerformanceWindowOneDay) label1 = [formatter stringFromDate:arr[item]];
            else label1 = [NSString stringWithFormat:@"%@ EST",[timeFormatter stringFromDate:arr[item]]];
            NSString *label2 = [NSString stringWithFormat:@"$%.2f", y];
            return [LCLineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
        };
        subdata;
    });
    self.chart = [[LCLineChartView alloc] initWithFrame:CGRectMake(0, 200, 370, 150)];
    [self.chart showLegend:NO animated:NO];
    self.chart.yMin = [self.stock.currentLow doubleValue] - fmod([self.stock.currentLow doubleValue], 0.1);
    self.chart.yMax = [self.stock.currentHigh doubleValue] + (.10-fmod([self.stock.currentHigh doubleValue], .10));
    double difference = self.chart.yMax - self.chart.yMin;
    double diffStep = difference/3.0;
    self.chart.ySteps = @[[NSString stringWithFormat:@"%.2f",self.chart.yMin], [NSString stringWithFormat:@"%.2f",self.chart.yMin+diffStep], [NSString stringWithFormat:@"%.2f",self.chart.yMin+(2*diffStep)], [NSString stringWithFormat:@"%.2f",self.chart.yMax]];
    self.chart.data = @[data];
    __weak typeof(self) weakSelf = self;
    self.chart.selectedItemCallback = ^(LCLineChartData *dat, NSUInteger item, CGPoint pos) {
        //NSLog(@"User selected item 1 in 1st graph at position %@ in the graph view", NSStringFromCGPoint(pos));
        weakSelf.priceLabel.text = data.getData(item).dataLabel;
    };
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
