//
//  MenuVC.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/19/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import "CoreDataLayer.h"
#import "BubblesVC.h"

@class PortfolioVC;

@interface MenuVC : UIViewController

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) CoreDataLayer *coreDataLayer;
@property (strong, nonatomic) PortfolioVC *parent;
@property (assign, nonatomic) BOOL isInFakeStockMode;

-(IBAction)close:(id)sender;

@end
