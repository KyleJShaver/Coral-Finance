//
//  ViewController.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/4/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.timePeriodPicker addTarget:self action:@selector(timePeriodChanged:) forControlEvents:UIControlEventValueChanged];
    [self.timePeriodPicker setSelectedSegmentIndex:0];
    [self timePeriodChanged:self.timePeriodPicker];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RealStockDelegate

-(void)realStockError:(NSError *)error downloadingInformation:(RealStock *)realStock
{
    NSLog(@"%@",error.description);
}

-(void)realStockDoneDownloading:(RealStock *)realStock
{
    self.chart = [[CFStockChart alloc] initWithStock:realStock];
    self.chart.chart.alpha = 0;
    [self.view addSubview:self.chart.chart];
    [UIView animateWithDuration:0.2 animations:^{
        self.chart.chart.alpha = 1;
    }];
}

-(void)realStockDidDownloadRequestedInformation:(RealStock *)realStock
{
    
}

-(void)realStockDidDownloadYearInformation:(RealStock *)realStock
{
    
}

-(void)realStockDidDownloadCurrentInformation:(RealStock *)realStock
{
    
}

#pragma mark - Animation Helpers



#pragma mark - UISegmentedControl

-(void)timePeriodChanged:(UISegmentedControl *)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        self.stock.delegate = nil;
        self.chart.chart.alpha = 0;
    } completion:^(BOOL finished) {
        for(int i=(int)self.view.subviews.count-1; i>=0; i--) {
            UIView *temp = self.view.subviews[i];
            if([temp isKindOfClass:[LCLineChartView class]]) [temp removeFromSuperview];
        }
        [self.chart.chart removeFromSuperview];
        self.chart = nil;
        PerformanceWindow window;
        switch (self.timePeriodPicker.selectedSegmentIndex) {
            case 0:
                window = PerformanceWindowOneDay;
                break;
            case 1:
                window = PerformanceWindowOneMonth;
                break;
            case 2:
                window = PerformanceWindowThreeMonth;
                break;
            case 3:
                window = PerformanceWindowSixMonth;
                break;
            case 4:
                window = PerformanceWindowOneYear;
                break;
            case 5:
                window = PerformanceWindowTwoYear;
                break;
            default:
                window = PerformanceWindowOneDay;
                break;
        }
        self.stock = [[RealStock alloc] initWithTicker:[self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] performanceWindow:window andDelegate:self];
        [self.stock downloadStockData];
    }];
}

#pragma mark - UISearchBar Delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self timePeriodChanged:nil];
}

@end
