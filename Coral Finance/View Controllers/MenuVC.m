//
//  MenuVC.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/19/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "MenuVC.h"
#import "PortfolioVC.h"

@interface MenuVC ()

@end

@implementation MenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[Globals bebasBook:16]
                                                           forKey:NSFontAttributeName];
    [self.segmentedControl setTitleTextAttributes:attributes
                                         forState:UIControlStateNormal];
    [self.segmentedControl addTarget:self action:@selector(toggleFakeStockMode) forControlEvents:UIControlEventValueChanged];
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.isInFakeStockMode) [self.segmentedControl setSelectedSegmentIndex:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)toggleFakeStockMode
{
    self.isInFakeStockMode = (self.segmentedControl.selectedSegmentIndex == 1) ? YES : NO;
    [self.coreDataLayer setIsInFakeStockMode:self.isInFakeStockMode];
    self.parent.isInFakeStockMode = self.isInFakeStockMode;
    [self.parent changeRealFakeStocks];
    [self close:self];
}

-(IBAction)close:(id)sender
{
    [UIView animateWithDuration:0.4 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        [self.parent checkExchangeOpen];
    }];
    
}

-(IBAction)portfolio:(id)sender
{
    PortfolioVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"home"];
    [self addChildViewController:vc];
    vc.view.alpha = 0;
    [self.view addSubview:vc.view];
    vc.isInFakeStockMode = self.isInFakeStockMode;
    [vc.tableView reloadData];
    [UIView animateWithDuration:0.4 animations:^{
        self.view.alpha = 1;
        vc.view.alpha = 1;
    } completion:^(BOOL finished) {
        vc.view.alpha = 1;
        self.view.alpha = 1;
    }];
    vc.isChildViewController = YES;
    [vc overviewMode];
    [vc checkViewControllerStatus];
    [vc.tableView setUserInteractionEnabled:YES];
    [vc.tableView setScrollEnabled:NO];
    vc.tableData = @[];
    vc.stock = nil;
    vc.didCheckOwned = NO;
}

-(IBAction)bubbles:(id)sender
{
    BubblesVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"bubbles"];
    vc.view.frame = self.view.frame;
    vc.view.alpha = 0;
    [self.view addSubview:vc.view];
    [self addChildViewController:vc];
    [vc didMoveToParentViewController:self];
    [UIView animateWithDuration:0.4 animations:^{
        vc.view.alpha = 1;
    } completion:^(BOOL finished) {
        vc.view.alpha = 1;
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
