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
    self.isChildViewController = NO;
    self.showPercentages = NO;
    self.coreDataLayer = [[CoreDataLayer alloc] initWithContext:((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext];
    self.tableData = @[];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[Globals bebasBook:16]
                                                           forKey:NSFontAttributeName];
    [self.timePeriodPicker setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    [self.timePeriodPicker addTarget:self action:@selector(timePeriodChanged:) forControlEvents:UIControlEventValueChanged];
    [self.timePeriodPicker setSelectedSegmentIndex:0];
    [self timePeriodChanged:self.timePeriodPicker];
    self.priceLabel.font = [Globals bebasLight:40];
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(!self.isChildViewController) {
        [self setTableDataFromCoreData];
    }
}

-(void)checkViewControllerStatus
{
    if(self.isChildViewController) {
        [self.menuButton setImage:[UIImage imageNamed:@"x.png"] forState:UIControlStateNormal];
        self.searchButton.alpha = 0;
    }
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
        else if(hourInt == 9) {
            if(comps.minute <= 30) self.marketStatusLabel.text = @"market closed";
        }
        else if(hourInt > 16) self.marketStatusLabel.text = @"market closed";
        else self.marketStatusLabel.text = @"market open";
    }
    else {
        self.marketStatusLabel.text = @"market closed";
    }
}

-(void)resetPrice
{
    if(!self.stock || !self.stock.currentValue) self.priceLabel.text = @"";
    else self.priceLabel.text = [NSString stringWithFormat:@"$%@",[Globals numberToString:self.stock.currentValue]];
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
        cell.currentPriceLabel.font = [Globals bebasLight:30];
        NSString *performance = [stock dailyPerformanceValue];
        if(self.showPercentages) performance = [stock dailyPerformancePercent];
        if(performance && [performance rangeOfString:@"-"].location!=NSNotFound)
            cell.performanceButton.backgroundColor = [Globals negativeColor];
        else
            cell.performanceButton.backgroundColor = [Globals positiveColor];
        [cell.performanceButton setTitle:performance forState:UIControlStateNormal];
        cell.performanceButton.layer.cornerRadius = 5;
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = [Globals darkBackgroundColor];
        [cell.performanceButton setUserInteractionEnabled:NO];
        return cell;
    }
    else {
        ExpandedStockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"expandedCell"];
        cell.tickerSymbolLabel.text = stock.tickerSymbol;
        if(stock.currentValue) {
            cell.currentPriceLabel.text = [NSString stringWithFormat:@"$%@",[Globals numberToString:stock.currentValue]];
            cell.currentPriceLabel.font = [Globals bebasLight:30];
            NSString *performance = [stock dailyPerformanceValue];
            if(self.showPercentages) performance = [stock dailyPerformancePercent];
            if(performance && [performance rangeOfString:@"-"].location!=NSNotFound)
                cell.performanceButton.backgroundColor = [Globals negativeColor];
            else
                cell.performanceButton.backgroundColor = [Globals positiveColor];
            if(!self.showPercentages) {
                cell.returnPercentDescLabel.text = @"Return Value";
                cell.returnPercentLabel.text = [stock overallPerformanceValue];
            }
            else {
                cell.returnPercentDescLabel.text = @"Return Percent";
                cell.returnPercentLabel.text = [stock overallPerformancePercent];
            }
            [cell.performanceButton setTitle:performance forState:UIControlStateNormal];
            cell.companyNameLabel.text = stock.companyName;
            cell.coreDataLayer = self.coreDataLayer;
            cell.stock = stock;
            cell.parent = self;
            cell.sharesOwnedLabel.text = [NSString stringWithFormat:@"%d",[stock.quantityOwned intValue]];
            double equityValue = [stock.currentValue doubleValue]*(double)[stock.quantityOwned intValue];
            cell.equityValueLabel.text = [NSString stringWithFormat:@"$%@",[Globals numberToString:[NSNumber numberWithDouble:equityValue]]];
            //cell.returnPercentLabel.text = [stock overallPerformancePercent];
        }
        else {
            cell.currentPriceLabel.text = @"";
            //[cell.performanceButton setTitle:@"" forState:UIControlStateNormal];
            cell.companyNameLabel.text = @"";
            cell.coreDataLayer = nil;
            cell.stock = nil;
            cell.parent = nil;
        }
        [cell.performanceButton setUserInteractionEnabled:YES];
        cell.performanceButton.layer.cornerRadius = 5;
        cell.buyButton.layer.cornerRadius = 5;
        cell.sellButton.layer.cornerRadius = 5;
        if(!self.isChildViewController) {
            cell.selectedBackgroundView = [UIView new];
            cell.selectedBackgroundView.backgroundColor = [Globals darkBackgroundColor];
        }
        else {
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isChildViewController) return;
    [self clearAllCharts];
    RealStock *stock = (RealStock *)self.tableData[indexPath.row];
    if([self.stock.tickerSymbol isEqualToString:stock.tickerSymbol]) {
        self.stock = nil;
        [self clearAllCharts];
        self.priceLabel.text = @"";
    }
    else {
        [self clearAllCharts];
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
    self.chart = nil;
    if(!self.isChildViewController) {
        self.tableData = [self.coreDataLayer getOwnedStocksWithDelegate:self];
    }
    else {
        NSArray *owned = [self.coreDataLayer getOwnedStockWithStock:self.stock andDelegate:self];
        if(self.didCheckOwned || owned!=nil) {
            self.tableData = owned;
        }
        self.didCheckOwned = YES;
    }
    BOOL tableDataHasStock = NO;
    for(int i=0; i<self.tableData.count; i++) {
        RealStock *stock = self.tableData[i];
        if([stock.tickerSymbol isEqualToString:self.stock.tickerSymbol]) {
            tableDataHasStock = YES;
        }
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
        [stock downloadCurrentData];
    }
    if(!tableDataHasStock) {
        self.stock = nil;
        [self clearAllCharts];
        if(self.isChildViewController) {
            [self showMenu:self];
        }
    }
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tickerSymbol"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.tableData = [self.tableData sortedArrayUsingDescriptors:sortDescriptors];
    [self.tableView reloadData];
}

-(void)toggleShowPercent
{
    if(self.showPercentages) self.showPercentages = NO;
    else self.showPercentages = YES;
    [self.tableView reloadData];
}

#pragma mark - Chart Stuff

-(void)clearAllCharts
{
    self.priceLabel.text = @"";
    NSMutableArray *array = [[self.chartContainer subviews] mutableCopy];
    for(int i=(int)array.count-1; i>=0; i--) {
        UIView *view = array[i];
        if(![view isKindOfClass:[LCLineChartView class]]) {
            [array removeObjectAtIndex:i];
        }
    }
    [array makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - UISegmentedControl

-(void)timePeriodChanged:(UISegmentedControl *)sender
{
    if(!self.stock) return;
    [UIView animateWithDuration:0.2 animations:^{
        self.stock.delegate = nil;
        self.chart.chart.alpha = 0;
    } completion:^(BOOL finished) {
        [self clearAllCharts];
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
    CGRect frame = self.chartContainer.bounds;
    frame.origin.y += 36;
    frame.size.height -= 36;
    frame.size.width -= 50;
    frame.origin.x += 20;
    self.chart.chart.frame = frame;
    [self clearAllCharts];
    [self.chartContainer addSubview:self.chart.chart];
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

-(IBAction)showMenu:(id)sender
{
    if(self.isChildViewController) {
        [UIView animateWithDuration:0.4 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self willMoveToParentViewController:nil];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
        return;
    }
    MenuVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"menu"];
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

-(IBAction)showSearch:(id)sender
{
    SearchVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"search"];
    vc.coreDataLayer = self.coreDataLayer;
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


@end
