//
//  PurchasedRealStockObject.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/19/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RealStockObject;

@interface PurchasedRealStockObject : NSManagedObject

@property (nonatomic, retain) NSNumber * purchasePrice;
@property (nonatomic, retain) NSDate * purchaseDate;
@property (nonatomic, retain) NSNumber * quantityPurchased;
@property (nonatomic, retain) RealStockObject *stock;

@end
