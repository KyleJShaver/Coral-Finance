//
//  SearchVC.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/19/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "CoreDataLayer.h"
#import "CoreStockObject.h"
#import "StockCellWithName.h"

@interface SearchVC : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, RealStockDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *tableData;
@property (strong, nonatomic) NSArray *rawArray;
@property (strong, nonatomic) CoreDataLayer *coreDataLayer;

-(IBAction)close:(id)sender;

@end
