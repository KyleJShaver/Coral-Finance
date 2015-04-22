//
//  PriceTime.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/5/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PriceTime : NSObject

@property (strong, nonatomic) NSNumber *utcTime;
@property (strong, nonatomic) NSNumber *price;

+(instancetype) priceTimeFromCoreDataDictionary:(NSDictionary *)priceTimeDictionary;
-(id)initWithDictionary:(NSDictionary *)inputDictionary;
-(NSDate *)timeAsDate;
-(NSDictionary *)dictionaryValue;

@end
