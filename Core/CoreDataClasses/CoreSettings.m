//
//  CoreSettings.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/21/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "CoreSettings.h"


@implementation CoreSettings

@dynamic isModeFakeStocks;
@dynamic dateUpdated;

+(instancetype)fetchWithContext:(NSManagedObjectContext *)managedObjectContext
{
    NSError *error;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    NSArray *object = [managedObjectContext executeFetchRequest:request error:&error];
    if(error) {
        NSLog(@"%@",error.description);
        return nil;
    }
    if(object.count==0) return nil;
    return object[0];
}

+(instancetype)newWithContext:(NSManagedObjectContext *)managedObjectContext
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:managedObjectContext];
}

@end
