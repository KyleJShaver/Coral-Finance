//
//  DataFetcher.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/17/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataFetcher;

@protocol DataFetcherDelegate <NSObject>

@required

-(void)dataFetcherDidDownloadData:(DataFetcher *)dataFetcher;

@optional

-(void)dataFetcherError:(NSError *)error downloadingData:(DataFetcher *)dataFetcher;

@end

typedef NS_ENUM(NSUInteger, DataFetchType) {
    DataFetchTypeRealStockList,
    DataFetchTypeFakeStockList,
};

@interface DataFetcher : NSObject

@property (strong, nonatomic) id<DataFetcherDelegate> delegate;
@property (strong, nonatomic) NSData *fetchedData;
@property DataFetchType fetchType;

+(instancetype)dataFetchWithType:(DataFetchType)fetchType andDelegate:(id<DataFetcherDelegate>)delegate;
-(void)fetch;

@end
