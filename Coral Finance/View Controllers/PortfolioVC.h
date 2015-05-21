//
//  PortfolioVC.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/18/15.
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
#import "StockCell.h"
#import "ExpandedStockCell.h"
#import "MenuVC.h"
#import "SearchVC.h"

@interface PortfolioVC : UIViewController <RealStockDelegate, DataFetcherDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) RealStock *stock;
@property (strong, nonatomic) CFStockChart *chart;
@property (strong, nonatomic) NSArray *tableData;
@property (strong, nonatomic) IBOutlet UISegmentedControl *timePeriodPicker;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *marketStatusLabel;
@property (strong, nonatomic) IBOutlet UIView *chartContainer;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) CoreDataLayer *coreDataLayer;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign, nonatomic) BOOL isChildViewController;
@property (assign, nonatomic) BOOL isInFakeStockMode;
@property (assign, nonatomic) BOOL isInPorfolioOverviewMode;
@property (assign, nonatomic) BOOL didCheckOwned;
@property (assign, nonatomic) BOOL showPercentages;
@property (assign, nonatomic) BOOL portfolioView;

-(void)checkViewControllerStatus;
-(void)changeRealFakeStocks;
-(void)checkExchangeOpen;
-(void)toggleShowPercent;
-(void)setTableDataFromCoreData;
-(void)clearAllCharts;
-(void)overviewMode;
-(IBAction)showMenu:(id)sender;
-(IBAction)showSearch:(id)sender;

@end
