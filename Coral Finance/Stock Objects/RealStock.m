//
//  RealStock.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/4/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "RealStock.h"

#define URL @"http://chartapi.finance.yahoo.com/instrument/1.1/[TICKER]/chartdata;type=quote;range=[DATERANGE]/json/"

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
@synthesize performanceWindow = _performanceWindow;

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

-(NSString *)numberToString:(NSNumber *)number
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"#,##0.##"];
    return [formatter stringFromNumber:number];
}

-(NSString *)currentValueString
{
    return [NSString stringWithFormat:@"$%@",[self numberToString:self.currentValue]];
}

-(void)downloadStockData
{
    if(!_delegate) return;
    if(!_tickerSymbol) [_delegate realStockError:nil downloadingInformation:self];
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
            [_delegate realStockError:connectionError downloadingInformation:self];
            return;
        }
        NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        responseStr = [responseStr substringWithRange:NSMakeRange([@"finance_charts_json_callback( " length], [responseStr length]-2-[@"finance_charts_json_callback( " length])];
        
        NSError *error;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if(!error) {
            _companyName = [[jsonDictionary valueForKey:@"meta"] valueForKey:@"Company-Name"];
            if(!_companyName || [_companyName isEqualToString:@""]) {
               [_delegate realStockDoneDownloading:nil];
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
            [_delegate realStockDidDownloadRequestedInformation:self];
            if(_performanceWindow == PerformanceWindowOneDay) {
                _currentValue = ((PriceTime *)[_performanceValues lastObject]).price;
                didGetDay = YES;
                [_delegate realStockDidDownloadCurrentInformation:self];
            }
            else if(_performanceWindow == PerformanceWindowOneYear) {
                _yearHigh = _currentHigh;
                _yearLow = _currentLow;
                didGetYear = YES;
                [_delegate realStockDidDownloadYearInformation:self];
            }
            [self checkDoneDownloading];
        }
        else [_delegate realStockError:error downloadingInformation:self];
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
                didGetYear = YES;
                [_delegate realStockDidDownloadYearInformation:self];
                [self checkDoneDownloading];
            }
            else [_delegate realStockError:error downloadingInformation:self];
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
                [_delegate realStockDidDownloadCurrentInformation:self];
                [self checkDoneDownloading];
            }
            else [_delegate realStockError:error downloadingInformation:self];
        }];
    }
    else {
        _yearHigh = _currentHigh;
        _yearLow = _currentLow;
    }
}

-(void)checkDoneDownloading
{
    if(didGetDay && didGetRequested && didGetYear) [_delegate realStockDoneDownloading:self];
}

@end
