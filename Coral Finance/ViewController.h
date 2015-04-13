//
//  ViewController.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/4/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RealStock.h"
#import "CFStockChart.h"

@interface ViewController : UIViewController <RealStockDelegate, UISearchBarDelegate>

@property (strong, nonatomic) RealStock *stock;
@property (strong, nonatomic) CFStockChart *chart;
@property (strong, nonatomic) IBOutlet UISegmentedControl *timePeriodPicker;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

