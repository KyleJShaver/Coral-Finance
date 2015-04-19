//
//  CoreDataLayer.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/17/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RealStocks.h"
#import "RealStockWatchList.h"
#import "RealStockObject.h"

@interface CoreDataLayer : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(id)initWithContext:(NSManagedObjectContext *)context;
-(NSArray *)getRealStockJSON;
-(void)saveRealStockJSON:(NSData *)jsonData;

@end
