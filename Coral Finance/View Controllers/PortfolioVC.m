//
//  PortfolioVC.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/18/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "PortfolioVC.h"

@interface PortfolioVC ()

@end

@implementation PortfolioVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.coreDataLayer = [[CoreDataLayer alloc] initWithContext:((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext];
    self.tableData = @[];
    [self.timePeriodPicker addTarget:self action:@selector(timePeriodChanged:) forControlEvents:UIControlEventValueChanged];
    [self.timePeriodPicker setSelectedSegmentIndex:0];
    [self timePeriodChanged:self.timePeriodPicker];
    NSArray *jsonDictionary = [self.coreDataLayer getRealStockJSON];
    if(!jsonDictionary) [[DataFetcher dataFetchWithType:DataFetchTypeRealStockList andDelegate:self] fetch];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i=0; i<20; i++) {
        NSDictionary *dict = jsonDictionary[i];
        RealStock *stock =[[RealStock alloc] initWithTicker:[dict valueForKey:@"symbol"] performanceWindow:PerformanceWindowOneDay andDelegate:nil];
        [stock downloadCurrentData];
        [array addObject:stock];
    }
    self.tableData = array;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RealStock *stock = (RealStock *)self.tableData[indexPath.row];
    if(!self.stock || ![self.stock.tickerSymbol isEqualToString:stock.tickerSymbol]) {
        StockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"stockCell"];
        cell.tickerSymbolLabel.text = stock.tickerSymbol;
        cell.currentPriceLabel.text = [NSString stringWithFormat:@"$%@",stock.currentValue];
        NSString *performance = [stock dailyPerformancePercent];
        if(performance && [performance rangeOfString:@"-"].location!=NSNotFound)
            cell.performanceButton.backgroundColor = [Globals negativeColor];
        else
            cell.performanceButton.backgroundColor = [Globals positiveColor];
        [cell.performanceButton setTitle:performance forState:UIControlStateNormal];
        cell.performanceButton.layer.cornerRadius = 5;
        return cell;
    }
    else {
        ExpandedStockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"extendedCell"];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RealStock *stock = (RealStock *)self.tableData[indexPath.row];
    self.stock = stock;
    [self.tableView reloadData];
}

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
        self.stock = [[RealStock alloc] initWithTicker:[@"GOOG" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] performanceWindow:window andDelegate:self];
        [self.stock downloadStockData];
    }];
}

#pragma mark - DataFetcherDelegate

-(void)dataFetcherDidDownloadData:(DataFetcher *)dataFetcher
{
    if(dataFetcher.fetchType==DataFetchTypeRealStockList) {
        [self.coreDataLayer saveRealStockJSON:dataFetcher.fetchedData];
    }
    else {
        
    }
}

#pragma mark - RealStockDelegate

-(void)realStockError:(NSError *)error downloadingInformation:(RealStock *)realStock
{
    NSLog(@"%@",error.description);
}

-(void)realStockDoneDownloading:(RealStock *)realStock
{
    self.chart = [[CFStockChart alloc] initWithStock:realStock];
    self.chart.priceLabel = self.priceLabel;
    self.chart.chart.alpha = 0;
    CGRect frame = self.chartContainer.frame;
    frame.origin.y += 36;
    frame.size.height -= 36;
    frame.size.width -= 40;
    frame.origin.x += 20;
    self.chart.chart.frame = frame;
    [self.view addSubview:self.chart.chart];
    [UIView animateWithDuration:0.2 animations:^{
        self.chart.chart.alpha = 1;
    }];
    self.priceLabel.text = [NSString stringWithFormat:@"$%@",self.stock.currentValue];
    [self.tableView reloadData];
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

#pragma mark - Button Controls

-(IBAction)update:(id)sender
{
    [self.tableView reloadData];
}


@end
