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

@end
