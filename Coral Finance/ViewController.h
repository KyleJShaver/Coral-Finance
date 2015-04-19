//
//  ViewController.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/4/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "RealStock.h"
#import "CFStockChart.h"
#import "Globals.h"
#import "AppDelegate.h"
#import "DataFetcher.h"
#import "CoreDataLayer.h"

@interface ViewController : UIViewController <RealStockDelegate, UISearchBarDelegate, UISearchBarDelegate, DataFetcherDelegate>

@property (strong, nonatomic) RealStock *stock;
@property (strong, nonatomic) CFStockChart *chart;
@property (strong, nonatomic) IBOutlet UISegmentedControl *timePeriodPicker;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) CoreDataLayer *coreDataLayer;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

