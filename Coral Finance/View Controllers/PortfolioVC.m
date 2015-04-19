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
    if(!jsonDictionary || jsonDictionary.count==0) [[DataFetcher dataFetchWithType:DataFetchTypeRealStockList andDelegate:self] fetch];
    else {
        [self setTableDataFromCoreData];
    }
    [self checkExchangeOpen];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)checkExchangeOpen
{
    NSDate *now = [NSDate date];
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitWeekday) fromDate:now];
    NSDateFormatter *hour = [[NSDateFormatter alloc] init];
    [hour setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"hh" options:0 locale:[NSLocale currentLocale]]];
    [hour setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    
    if(comps.weekday != 1 && comps.day != 7) {
        int hourInt = [[hour stringFromDate:now] intValue];
        if(hourInt < 9) self.marketStatusLabel.text = @"market closed";
        else if(hourInt == 4) {
            if(comps.minute >= 30) self.marketStatusLabel.text = @"market closed";
        }
        else if(hourInt > 4) self.marketStatusLabel.text = @"market closed";
        else self.marketStatusLabel.text = @"market open";
    }
    else {
        self.marketStatusLabel.text = @"market closed";
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RealStock *stock = (RealStock *)self.tableData[indexPath.row];
    if(!self.stock || ![self.stock.tickerSymbol isEqualToString:stock.tickerSymbol])
        return 47;
    else return 159;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RealStock *stock = (RealStock *)self.tableData[indexPath.row];
    if(!self.stock || ![self.stock.tickerSymbol isEqualToString:stock.tickerSymbol]) {
        StockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"stockCell"];
        cell.tickerSymbolLabel.text = stock.tickerSymbol;
        if(stock.currentValue)
            cell.currentPriceLabel.text = [NSString stringWithFormat:@"$%@",[Globals numberToString:stock.currentValue]];
        else cell.currentPriceLabel.text = @"";
        NSString *performance = [stock dailyPerformancePercent];
        if(performance && [performance rangeOfString:@"-"].location!=NSNotFound)
            cell.performanceButton.backgroundColor = [Globals negativeColor];
        else
            cell.performanceButton.backgroundColor = [Globals positiveColor];
        [cell.performanceButton setTitle:performance forState:UIControlStateNormal];
        cell.performanceButton.layer.cornerRadius = 5;
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [Globals darkBackgroundColor];
        return cell;
    }
    else {
        ExpandedStockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"expandedCell"];
        cell.tickerSymbolLabel.text = stock.tickerSymbol;
        if(stock.currentValue) {
            cell.currentPriceLabel.text = [NSString stringWithFormat:@"$%@",[Globals numberToString:stock.currentValue]];
            NSString *performance = [stock dailyPerformancePercent];
            if(performance && [performance rangeOfString:@"-"].location!=NSNotFound)
                cell.performanceButton.backgroundColor = [Globals negativeColor];
            else
                cell.performanceButton.backgroundColor = [Globals positiveColor];
            [cell.performanceButton setTitle:performance forState:UIControlStateNormal];
            cell.companyNameLabel.text = stock.companyName;
        }
        else {
            cell.currentPriceLabel.text = @"";
            [cell.performanceButton setTitle:@"" forState:UIControlStateNormal];
            cell.companyNameLabel.text = @"";
        }
        
        cell.performanceButton.layer.cornerRadius = 5;
        cell.buyButton.layer.cornerRadius = 5;
        cell.sellButton.layer.cornerRadius = 5;
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [Globals darkBackgroundColor];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RealStock *stock = (RealStock *)self.tableData[indexPath.row];
    if([self.stock.tickerSymbol isEqualToString:stock.tickerSymbol]) {
        self.stock = nil;
        [self.chart.chart removeFromSuperview];
        self.priceLabel.text = @"";
    }
    else {
        [self.chart.chart removeFromSuperview];
        self.priceLabel.text = @"";
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
        stock.performanceWindow = window;
        stock.delegate = self;
        self.stock = stock;
        [self.stock downloadStockData];
    }
    [self.tableView reloadData];
}

-(void)setTableDataFromCoreData
{
    NSArray *jsonDictionary = [self.coreDataLayer getRealStockJSON];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i=0; i<20; i++) {
        NSDictionary *dict = jsonDictionary[i];
        RealStock *stock =[[RealStock alloc] initWithTicker:[dict valueForKey:@"symbol"] performanceWindow:PerformanceWindowOneDay andDelegate:self];
        [stock downloadCurrentData];
        [array addObject:stock];
    }
    self.tableData = array;
    [self.tableView reloadData];
}

#pragma mark - UISegmentedControl

-(void)timePeriodChanged:(UISegmentedControl *)sender
{
    if(!self.stock) return;
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
        self.stock = [[RealStock alloc] initWithTicker:[self.stock.tickerSymbol stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] performanceWindow:window andDelegate:self];
        [self.stock downloadStockData];
    }];
}

#pragma mark - DataFetcherDelegate

-(void)dataFetcherDidDownloadData:(DataFetcher *)dataFetcher
{
    if(dataFetcher.fetchType==DataFetchTypeRealStockList) {
        [self.coreDataLayer saveRealStockJSON:dataFetcher.fetchedData];
        [self setTableDataFromCoreData];
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
    if(![realStock.tickerSymbol isEqualToString:self.stock.tickerSymbol]) {
        [self.tableView reloadData];
        return;
    }
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
    self.priceLabel.text = [NSString stringWithFormat:@"$%@",[Globals numberToString:self.stock.currentValue]];
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
