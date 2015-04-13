//
//  PriceTime.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/5/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "PriceTime.h"

@implementation PriceTime

@synthesize price = _price;
@synthesize utcTime = _utcTime;

-(id)initWithDictionary:(NSDictionary *)inputDictionary;
{
    self = [super init];
    _price = [NSNumber numberWithDouble:[[inputDictionary valueForKey:@"close"] doubleValue]];
    NSString *dateCheck = [[inputDictionary  valueForKey:@"Date"] stringValue];
    if(!dateCheck || [dateCheck isEqualToString:@""]) {
        _utcTime = [NSNumber numberWithDouble:[[inputDictionary valueForKey:@"Timestamp"] doubleValue]];
    }
    else {
        _utcTime = [self yyyymmddToUnixTime:dateCheck];
    }
    return self;
}

-(NSDate *)timeAsDate
{
    if(!self.utcTime) return nil;
    else {
        return [NSDate dateWithTimeIntervalSince1970:[_utcTime doubleValue]];
    }
    return nil;
}

-(NSNumber *)yyyymmddToUnixTime:(NSString *)dateString
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSNumber *day = [NSNumber numberWithInt:[[dateString substringWithRange:NSMakeRange(6, 2)] intValue]];
    NSNumber *month = [NSNumber numberWithInt:[[dateString substringWithRange:NSMakeRange(4, 2)] intValue]];
    NSNumber *year = [NSNumber numberWithInt:[[dateString substringWithRange:NSMakeRange(0, 4)] intValue]];
    [components setDay:[day intValue]];
    [components setMonth:[month intValue]];
    [components setYear:[year intValue]];
    [components setHour:16];
    [components setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    NSDate *date = [calendar dateFromComponents:components];
    return [NSNumber numberWithLong:[date timeIntervalSince1970]];
}

@end
