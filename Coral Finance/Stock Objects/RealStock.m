//
//  RealStock.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/4/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "RealStock.h"

#define URL @"http://chartapi.finance.yahoo.com/instrument/1.1/[TICKER]/chartdata;type=quote;range=[DATERANGE]/json/"
#define FAKE_URL @"http://coral.finance/api/v1/?query=stock&symbol=[TICKER]"

@implementation RealStock

@synthesize delegate = _delegate;
@synthesize companyName = _companyName;
@synthesize tickerSymbol = _tickerSymbol;
@synthesize currentValue = _currentValue;
@synthesize currentHigh = _currentHigh;
@synthesize currentLow = _currentLow;
@synthesize openingValue = _openingValue;
@synthesize marketCap = _marketCap;
@synthesize yearHigh = _yearHigh;
@synthesize yearLow = _yearLow;
@synthesize performanceValues = _performanceValues;
@synthesize performanceValuesDay = _performanceValuesDay;
@synthesize performanceValuesYear = _performanceValuesYear;
@synthesize performanceWindow = _performanceWindow;
@synthesize quantityOwned = _quantityOwned;
@synthesize totalSpent = _totalSpent;

bool didGetRequested;
bool didGetDay;
bool didGetYear;

-(id)initWithDelegate:(id<RealStockDelegate>)delegate
{
    self = [super init];
    self.delegate = delegate;
    self.performanceWindow = PerformanceWindowOneDay;
    return self;
}

-(id)initWithTicker:(NSString *)tickerSymbol andDelegate:(id<RealStockDelegate>)delegate
{
    self = [super init];
    self.delegate = delegate;
    self.tickerSymbol = tickerSymbol;
    self.performanceWindow = PerformanceWindowOneDay;
    return self;
}

-(id)initWithTicker:(NSString *)tickerSymbol performanceWindow:(PerformanceWindow)performanceWindow andDelegate:(id<RealStockDelegate>)delegate
{
    self = [super init];
    self = [self initWithTicker:tickerSymbol andDelegate:delegate];
    self.performanceWindow = performanceWindow;
    return self;
}

+(instancetype) stockWithCoreStockObject:(CoreStockObject *)coreStockObject andDelegate:(id<RealStockDelegate>)delegate
{
    RealStock *stock = [[RealStock alloc] init];
    stock.delegate = delegate;
    stock.tickerSymbol = coreStockObject.tickerSymbol;
    stock.companyName = coreStockObject.companyName;
    stock.quantityOwned = coreStockObject.quantityOwned;
    stock.totalSpent = coreStockObject.totalPaid;
    stock.isFakeStock = [coreStockObject.isFakeStock boolValue];
    return stock;
}

-(NSString *)numberToString:(NSNumber *)number
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"#,##0.00"];
    return [formatter stringFromNumber:number];
}

-(NSString *)currentValueString
{
    return [NSString stringWithFormat:@"$%@",[self numberToString:self.currentValue]];
}

-(NSString *)dailyPerformanceValue
{
    if(!_currentValue || !_openingValue) return nil;
    double difference = [_currentValue doubleValue] - [_openingValue doubleValue];
    return [NSString stringWithFormat:@"$%@",[self numberToString:[NSNumber numberWithDouble:difference]]];
}

-(NSString *)dailyPerformanceValuePortfolio
{
    if(!_currentValue) return nil;
    double difference = [_currentValue doubleValue] - [_totalSpent doubleValue];
    return [NSString stringWithFormat:@"$%@",[self numberToString:[NSNumber numberWithDouble:difference]]];
}

-(NSString *)dailyPerformancePercent
{
    if(!_currentValue || !_openingValue) return nil;
    double difference = [_currentValue doubleValue] - [_openingValue doubleValue];
    difference /= [_openingValue doubleValue];
    difference *= 100;
    return [NSString stringWithFormat:@"%@%%",[self numberToString:[NSNumber numberWithDouble:difference]]];
}

-(NSString *)dailyPerformancePercentPortfolio
{
    if(!_currentValue) return nil;
    double difference = [_currentValue doubleValue] - [_totalSpent doubleValue];
    difference /= [_totalSpent doubleValue];
    difference *= 100;
    return [NSString stringWithFormat:@"%@%%",[self numberToString:[NSNumber numberWithDouble:difference]]];
}

-(NSString *)overallPerformanceValue
{
    if(!_totalSpent || !_quantityOwned || !_currentValue) return [NSString stringWithFormat:@"$%@",[self numberToString:[NSNumber numberWithDouble:0]]];
    double difference = ([_currentValue doubleValue] * (double)[_quantityOwned intValue]) - [_totalSpent doubleValue];
    difference = ([[self numberToString:[NSNumber numberWithDouble:difference]] doubleValue]==0) ? 0.0 : difference;
    if(difference>=0) return [NSString stringWithFormat:@"$%@",[self numberToString:[NSNumber numberWithDouble:difference]]];
    else return [NSString stringWithFormat:@"-$%@",[self numberToString:[NSNumber numberWithDouble:(difference*-1.0)]]];
}

-(NSString *)overallPerformanceValuePortfolio
{
    if(!_totalSpent || !_quantityOwned || !_currentValue) return [NSString stringWithFormat:@"$%@",[self numberToString:[NSNumber numberWithDouble:0]]];
    double difference = [_currentValue doubleValue] - [_totalSpent doubleValue];
    difference = ([[self numberToString:[NSNumber numberWithDouble:difference]] doubleValue]==0) ? 0.0 : difference;
    if(difference>=0) return [NSString stringWithFormat:@"$%@",[self numberToString:[NSNumber numberWithDouble:difference]]];
    else return [NSString stringWithFormat:@"-$%@",[self numberToString:[NSNumber numberWithDouble:(difference*-1.0)]]];
}

-(NSString *)overallPerformancePercent
{
    if(!_totalSpent || !_quantityOwned || !_currentValue || [_totalSpent doubleValue]==0 || [_quantityOwned intValue]==0) return [NSString stringWithFormat:@"%@%%",[self numberToString:[NSNumber numberWithDouble:0]]];
    double difference = ([_currentValue doubleValue] * (double)[_quantityOwned intValue]) - [_totalSpent doubleValue];
    difference = ([[self numberToString:[NSNumber numberWithDouble:difference]] doubleValue]==0) ? 0.0 : difference;
    difference /= [_totalSpent doubleValue];
    difference *= 100;
    return [NSString stringWithFormat:@"%@%%",[self numberToString:[NSNumber numberWithDouble:difference]]];
}

-(NSString *)overallPerformancePercentPortfolio
{
    if(!_totalSpent || !_quantityOwned || !_currentValue || [_totalSpent doubleValue]==0 || [_quantityOwned intValue]==0) return [NSString stringWithFormat:@"%@%%",[self numberToString:[NSNumber numberWithDouble:0]]];
    double difference = [_currentValue doubleValue] - [_totalSpent doubleValue];
    difference = ([[self numberToString:[NSNumber numberWithDouble:difference]] doubleValue]==0) ? 0.0 : difference;
    difference /= [_totalSpent doubleValue];
    difference *= 100;
    return [NSString stringWithFormat:@"%@%%",[self numberToString:[NSNumber numberWithDouble:difference]]];
}

-(void)downloadStockData
{
    if(!_tickerSymbol && _delegate) [_delegate realStockError:nil downloadingInformation:self];
    didGetRequested = NO;
    didGetDay = NO;
    didGetYear = NO;
    NSString *urlStr = [URL stringByReplacingOccurrencesOfString:@"[TICKER]" withString:_tickerSymbol];
    NSString *performanceWindowStr = @"";
    switch (_performanceWindow) {
        case PerformanceWindowOneDay:
            performanceWindowStr = @"1d";
            break;
        case PerformanceWindowOneMonth:
            performanceWindowStr = @"1m";
            break;
        case PerformanceWindowThreeMonth:
            performanceWindowStr = @"3m";
            break;
        case PerformanceWindowSixMonth:
            performanceWindowStr = @"6m";
            break;
        case PerformanceWindowOneYear:
            performanceWindowStr = @"1y";
            break;
        case PerformanceWindowTwoYear:
            performanceWindowStr = @"1y";
            break;
        default:
            return;
            break;
    }
    NSString *urlWindowedStr = [urlStr stringByReplacingOccurrencesOfString:@"[DATERANGE]" withString:performanceWindowStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlWindowedStr]];
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError) {
            if(_delegate) [_delegate realStockError:connectionError downloadingInformation:self];
            return;
        }
        NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        responseStr = [responseStr substringWithRange:NSMakeRange([@"finance_charts_json_callback( " length], [responseStr length]-2-[@"finance_charts_json_callback( " length])];
        
        NSError *error;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if(!error) {
            _companyName = [[jsonDictionary valueForKey:@"meta"] valueForKey:@"Company-Name"];
            if(!_companyName || [_companyName isEqualToString:@""]) {
               if(_delegate) [_delegate realStockDoneDownloading:nil];
                return;
            }
            if(_performanceWindow==PerformanceWindowOneDay)
                _openingValue = [NSNumber numberWithDouble:[[[jsonDictionary valueForKey:@"meta"] valueForKey:@"previous_close"] doubleValue]];
            else
                _openingValue = [NSNumber numberWithDouble:[[[jsonDictionary valueForKey:@"meta"] valueForKey:@"previous_close_price"] doubleValue]];
            _currentHigh = [NSNumber numberWithDouble:[[[[jsonDictionary valueForKey:@"ranges"] valueForKey:@"high"] valueForKey:@"max"] doubleValue]];
            _currentLow = [NSNumber numberWithDouble:[[[[jsonDictionary valueForKey:@"ranges"] valueForKey:@"low"] valueForKey:@"min"] doubleValue]];
            NSMutableArray *performanceValuesTemp = [[NSMutableArray alloc] init];
            NSArray *performanceValuesTempJson = [jsonDictionary valueForKey:@"series"];
            for(NSDictionary *tempDictionary in performanceValuesTempJson) {
                [performanceValuesTemp addObject:[[PriceTime alloc] initWithDictionary:tempDictionary]];
            }
            _performanceValues = performanceValuesTemp;
            didGetRequested = YES;
            if(_delegate) [_delegate realStockDidDownloadRequestedInformation:self];
            if(_performanceWindow == PerformanceWindowOneDay) {
                _performanceValuesDay = _performanceValues;
                _currentValue = ((PriceTime *)[_performanceValues lastObject]).price;
                didGetDay = YES;
                if(_delegate) [_delegate realStockDidDownloadCurrentInformation:self];
            }
            else if(_performanceWindow == PerformanceWindowOneYear) {
                _performanceValuesYear = _performanceValues;
                _yearHigh = _currentHigh;
                _yearLow = _currentLow;
                didGetYear = YES;
                if(_delegate) [_delegate realStockDidDownloadYearInformation:self];
            }
            [self checkDoneDownloading];
        }
        else if(_delegate) [_delegate realStockError:error downloadingInformation:self];
    }];
    if(_performanceWindow != PerformanceWindowOneYear) {
        NSString *urlYearStr = [urlStr stringByReplacingOccurrencesOfString:@"[DATERANGE]" withString:@"1y"];
        NSURLRequest *yearRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlYearStr]];
        [NSURLConnection sendAsynchronousRequest:yearRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSString *yearResponseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            yearResponseStr = [yearResponseStr substringWithRange:NSMakeRange([@"finance_charts_json_callback( " length], [yearResponseStr length]-2-[@"finance_charts_json_callback( " length])];
            
            NSError *error;
            NSDictionary *jsonYearDictionary = [NSJSONSerialization JSONObjectWithData:[yearResponseStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            if(!error) {
                _yearHigh = [NSNumber numberWithDouble:[[[[jsonYearDictionary valueForKey:@"ranges"] valueForKey:@"high"] valueForKey:@"max"] doubleValue]];
                _yearLow = [NSNumber numberWithDouble:[[[[jsonYearDictionary valueForKey:@"ranges"] valueForKey:@"low"] valueForKey:@"min"] doubleValue]];
                NSMutableArray *performanceValuesTemp = [[NSMutableArray alloc] init];
                NSArray *performanceValuesTempJson = [jsonYearDictionary valueForKey:@"series"];
                for(NSDictionary *tempDictionary in performanceValuesTempJson) {
                    [performanceValuesTemp addObject:[[PriceTime alloc] initWithDictionary:tempDictionary]];
                }
                _performanceValuesYear = performanceValuesTemp;
                didGetYear = YES;
                if(_delegate) [_delegate realStockDidDownloadYearInformation:self];
                [self checkDoneDownloading];
            }
            else if(_delegate) [_delegate realStockError:error downloadingInformation:self];
        }];
    }
    else {
        
    }
    if(_performanceWindow != PerformanceWindowOneDay) {
        NSString *urlDayStr = [urlStr stringByReplacingOccurrencesOfString:@"[DATERANGE]" withString:@"1d"];
        NSURLRequest *dayRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlDayStr]];
        [NSURLConnection sendAsynchronousRequest:dayRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSString *dayResponseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            dayResponseStr = [dayResponseStr substringWithRange:NSMakeRange([@"finance_charts_json_callback( " length], [dayResponseStr length]-2-[@"finance_charts_json_callback( " length])];
            
            NSError *error;
            NSDictionary *jsonDayDictionary = [NSJSONSerialization JSONObjectWithData:[dayResponseStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            if(!error) {
                NSArray *performanceValuesDayTempJson = [jsonDayDictionary valueForKey:@"series"];
                PriceTime *currentPrice = [[PriceTime alloc] initWithDictionary:[performanceValuesDayTempJson lastObject]];
                _currentValue = currentPrice.price;
                didGetDay = YES;
                NSMutableArray *performanceValuesTemp = [[NSMutableArray alloc] init];
                for(NSDictionary *tempDictionary in performanceValuesDayTempJson) {
                    [performanceValuesTemp addObject:[[PriceTime alloc] initWithDictionary:tempDictionary]];
                }
                _performanceValuesDay = performanceValuesTemp;
                if(_delegate) [_delegate realStockDidDownloadCurrentInformation:self];
                [self checkDoneDownloading];
            }
            else if(_delegate) [_delegate realStockError:error downloadingInformation:self];
        }];
    }
    else {
        _yearHigh = _currentHigh;
        _yearLow = _currentLow;
    }
}

-(void)downloadCurrentData
{
    if(!self.isFakeStock){
        NSString *urlStr = [URL stringByReplacingOccurrencesOfString:@"[TICKER]" withString:_tickerSymbol];
        NSString *urlWindowedStr = [urlStr stringByReplacingOccurrencesOfString:@"[DATERANGE]" withString:@"1d"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlWindowedStr]];
        NSOperationQueue *queue = [NSOperationQueue mainQueue];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if(connectionError) {
                if(_delegate) [_delegate realStockError:connectionError downloadingInformation:self];
                return;
            }
            NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            responseStr = [responseStr substringWithRange:NSMakeRange([@"finance_charts_json_callback( " length], [responseStr length]-2-[@"finance_charts_json_callback( " length])];
            
            NSError *error;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            if(!error) {
                _companyName = [[jsonDictionary valueForKey:@"meta"] valueForKey:@"Company-Name"];
                if(!_companyName || [_companyName isEqualToString:@""]) {
                    if(_delegate) [_delegate realStockDoneDownloading:nil];
                    return;
                }
                _openingValue = [NSNumber numberWithDouble:[[[jsonDictionary valueForKey:@"meta"] valueForKey:@"previous_close"] doubleValue]];
                _currentHigh = [NSNumber numberWithDouble:[[[[jsonDictionary valueForKey:@"ranges"] valueForKey:@"high"] valueForKey:@"max"] doubleValue]];
                _currentLow = [NSNumber numberWithDouble:[[[[jsonDictionary valueForKey:@"ranges"] valueForKey:@"low"] valueForKey:@"min"] doubleValue]];
                NSMutableArray *performanceValuesTemp = [[NSMutableArray alloc] init];
                NSArray *performanceValuesTempJson = [jsonDictionary valueForKey:@"series"];
                for(NSDictionary *tempDictionary in performanceValuesTempJson) {
                    [performanceValuesTemp addObject:[[PriceTime alloc] initWithDictionary:tempDictionary]];
                }
                _performanceValues = performanceValuesTemp;
                didGetDay = YES;
                _currentValue = ((PriceTime *)[_performanceValues lastObject]).price;
                if(_delegate) [_delegate realStockDoneDownloading:self];
            }
            else if(_delegate) [_delegate realStockError:error downloadingInformation:self];
        }];
    }
    else {
        NSString *urlStr = [FAKE_URL stringByReplacingOccurrencesOfString:@"[TICKER]" withString:[_tickerSymbol lowercaseString]];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
        NSOperationQueue *queue = [NSOperationQueue mainQueue];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if(connectionError) {
                if(_delegate) [_delegate realStockError:connectionError downloadingInformation:self];
                return;
            }
            NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            if(!error) {
                NSMutableArray *values = [[jsonDictionary valueForKey:@"trades"] mutableCopy];
                NSDate *now = [NSDate date];
                double difference = 43200.0;
                double step = difference/((double)values.count)-1.0;
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
                [components setHour:10];
                NSNumber *smallest = [NSNumber numberWithDouble:0.0];
                NSNumber *largest = [NSNumber numberWithDouble:0.0];
                for(int i=0; i<values.count; i++) {
                    NSInteger sec = step*((double)i);
                    [components setSecond:sec];
                    NSDate *modifiedDate = [[NSCalendar currentCalendar] dateFromComponents:components];
                    PriceTime *temp = [[PriceTime alloc] init];
                    temp.utcTime = [NSNumber numberWithDouble:[modifiedDate timeIntervalSince1970]];
                    temp.price = [NSNumber numberWithDouble:[values[i] doubleValue]];
                    values[i] = temp;
                }
                _performanceValuesDay = [values copy];
                for(int i=(int)values.count-1; i>=0; i--) {
                    PriceTime *time = values[i];
                    if(i!=0 && [time.utcTime doubleValue] > [[NSDate date] timeIntervalSince1970]) {
                        [values removeObjectAtIndex:i];
                    }
                    else {
                        if([time.price doubleValue]<[smallest doubleValue] || [smallest doubleValue]==0.0) smallest = time.price;
                        if([time.price doubleValue]>[largest doubleValue]) largest = time.price;
                    }
                }
                _performanceValues = [values copy];
                _openingValue = ((PriceTime *)[_performanceValues firstObject]).price;
                _currentValue = ((PriceTime *)[_performanceValues lastObject]).price;
                _currentHigh = largest;
                _currentLow = smallest;
                if(_delegate) [_delegate realStockDoneDownloading:self];
            }
            else if(_delegate) [_delegate realStockError:error downloadingInformation:self];
        }];
    }
}

-(void)checkDoneDownloading
{
    if(didGetDay && didGetRequested && didGetYear)
        if(_delegate) [_delegate realStockDoneDownloading:self];
}

-(NSString *)peformanceToJSON
{
    NSError *error;
    NSMutableArray *array = [NSMutableArray array];
    for(PriceTime *pt in self.performanceValues) {
        [array addObject:[pt dictionaryValue]];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSComparisonResult)compareSymbols:(RealStock *)otherObject {
    return [self.tickerSymbol compare:otherObject.tickerSymbol];
}

@end
