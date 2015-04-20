//
//  ExpandedStockCell.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/18/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "ExpandedStockCell.h"
#import "PortfolioVC.h"

@implementation ExpandedStockCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)buy:(id)sender {
    [self.coreDataLayer buyStock:self.stock withQuantity:1];
    [self.parent.chart.chart removeFromSuperview];
    for(RealStock *realStock in self.parent.tableData) {
        if([realStock.tickerSymbol isEqualToString:self.stock.tickerSymbol]) {
            realStock.quantityOwned = [NSNumber numberWithInt:[realStock.quantityOwned intValue]+1];
            realStock.totalSpent = [NSNumber numberWithDouble:[realStock.totalSpent doubleValue]+[self.stock.currentValue doubleValue]];
        }
    }
    [self.parent.tableView reloadData];
}

-(IBAction)sell:(id)sender
{
    [self.coreDataLayer buyStock:self.stock withQuantity:-1];
    [self.parent.chart.chart removeFromSuperview];
    [self.parent setTableDataFromCoreData];
}

@end
