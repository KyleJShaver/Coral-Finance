//
//  CoreSettings.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/21/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreSettings : NSManagedObject

@property (nonatomic, retain) NSNumber * isModeFakeStocks;
@property (nonatomic, retain) NSDate * dateUpdated;

+(instancetype)fetchWithContext:(NSManagedObjectContext *)managedObjectContext;
+(instancetype)newWithContext:(NSManagedObjectContext *)managedObjectContext;

@end
