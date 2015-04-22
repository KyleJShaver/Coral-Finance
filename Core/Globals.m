//
//  Globals.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/15/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "Globals.h"

@implementation Globals

+(UIColor *) whiteColor
{
    return [UIColor whiteColor];
}

+(UIColor *) backgroundColor
{
    return [UIColor colorWithRed:115.0/255.0 green:201.0/255.0 blue:191.0/255.0 alpha:1];
}

+(UIColor *) darkBackgroundColor
{
    return [UIColor colorWithRed:74.0/255.0 green:152.0/255.0 blue:149.0/255.0 alpha:1];
}

+(UIColor *) positiveColor
{
    return [UIColor colorWithRed:0.0/255.0 green:172.0/255.0 blue:131.0/255.0 alpha:1];
}

+(UIColor *) negativeColor
{
    return [UIColor colorWithRed:239.0/255.0 green:90.0/255.0 blue:51.0/255.0 alpha:1];
}

+(UIColor *) buttonColor
{
    return [UIColor colorWithRed:249.0/255.0 green:237.0/255.0 blue:126.0/255.0 alpha:1];
}

+(UIFont *) bebasBold:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"BebasNeueBold" size:fontSize];
}

+(UIFont *) bebasBook:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"BebasNeueBook" size:fontSize];
}

+(UIFont *) bebasLight:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"BebasNeueLight" size:fontSize];
}

+(UIFont *) bebasRegular:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"BebasNeueRegular" size:fontSize];
}

+(UIFont *) canterLight:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"CanterLight" size:fontSize];
}

+(NSString *)numberToString:(NSNumber *)number
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"#,##0.00"];
    return [formatter stringFromNumber:number];
}

+(BOOL)isRealExchangeOpen
{
    NSDate *now = [NSDate date];
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitWeekday) fromDate:now];
    NSDateFormatter *hour = [[NSDateFormatter alloc] init];
    [hour setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"HH" options:0 locale:[NSLocale currentLocale]]];
    [hour setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    
    if(comps.weekday != 1 && comps.day != 7) {
        int hourInt = [[hour stringFromDate:now] intValue];
        if(hourInt < 9 || hourInt > 16) return NO;
        else if(hourInt == 9) {
            if(comps.minute <= 30) return NO;
            else return YES;
        }
        else return YES;
    }
    else {
        return NO;
    }
}

+(BOOL)isFakeExchangeOpen
{
    NSDate *now = [NSDate date];
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitWeekday) fromDate:now];
    NSDateFormatter *hour = [[NSDateFormatter alloc] init];
    [hour setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"HH" options:0 locale:[NSLocale currentLocale]]];
    [hour setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    
    if(comps.weekday != 1 && comps.day != 7) {
        int hourInt = [[hour stringFromDate:now] intValue];
        if(hourInt < 9 || hourInt > 20) return NO;
        else if(hourInt == 9) {
            if(comps.minute <= 30) return NO;
            else return YES;
        }
        else return YES;
    }
    else {
        return NO;
    }
}


@end
