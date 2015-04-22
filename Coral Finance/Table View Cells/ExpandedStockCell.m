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
    NSMutableArray *tableData = [self.parent.tableData mutableCopy];
    NSUInteger index = [tableData indexOfObjectIdenticalTo:self.stock];
    self.stock = [self.coreDataLayer buyStock:self.stock withQuantity:1];
    self.parent.stock = self.stock;
    if(tableData.count>1) {
        [tableData removeObjectAtIndex:index];
        [tableData insertObject:self.stock atIndex:index];
        self.parent.tableData = tableData;
    }
    else self.parent.tableData = @[self.stock];
    [self.parent.tableView reloadData];
}

-(IBAction)sell:(id)sender
{
    NSMutableArray *tableData = [self.parent.tableData mutableCopy];
    NSUInteger index = [tableData indexOfObjectIdenticalTo:self.stock];
    self.stock = [self.coreDataLayer sellStock:self.stock withQuantity:1];
    self.parent.stock = self.stock;
    if(tableData.count>1) {
        [tableData removeObjectAtIndex:index];
        if([self.stock.quantityOwned intValue]>0)
            [tableData insertObject:self.stock atIndex:index];
        else [self.parent clearAllCharts];
        self.parent.tableData = tableData;
    }
    else if([self.stock.quantityOwned intValue]>0)
        self.parent.tableData = @[self.stock];
    else {
        self.parent.tableData = @[];
        [self.parent clearAllCharts];
        if([self.parent isChildViewController]) {
            [self.parent showMenu:self.parent];
        }
    }
    [self.parent.tableView reloadData];
}

-(IBAction)toggle:(id)sender
{
    [self.parent toggleShowPercent];
}

@end
