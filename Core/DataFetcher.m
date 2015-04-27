//
//  DataFetcher.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/17/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "DataFetcher.h"

@implementation DataFetcher

@synthesize delegate = _delegate;
@synthesize fetchedData = _fetchedData;
@synthesize fetchType = _fetchType;

+(instancetype)dataFetchWithType:(DataFetchType)fetchType andDelegate:(id<DataFetcherDelegate>)delegate
{
    DataFetcher *dataFetcher = [[DataFetcher alloc] init];
    dataFetcher.fetchType = fetchType;
    dataFetcher.delegate = delegate;
    return dataFetcher;
}

-(void)fetch
{
    NSString *url;
    switch (_fetchType) {
        case DataFetchTypeFakeStockList: url = @"http://coral.finance/api/v1/?query=list&market=coral"; break;
        case DataFetchTypeRealStockList: url = @"http://coral.finance/api/v1/?query=list"; break;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError) {
            [_delegate dataFetcherError:connectionError downloadingData:self];
            return;
        }
        _fetchedData = data;
        [_delegate dataFetcherDidDownloadData:self];
    }];
}

@end
