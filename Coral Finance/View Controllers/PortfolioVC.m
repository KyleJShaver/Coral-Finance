//
//  PortfolioVC.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/18/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "PortfolioVC.h"
#import "CoreStockObject.h"

@interface PortfolioVC ()

@end

@implementation PortfolioVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isChildViewController = NO;
    self.portfolioView = NO;
    self.showPercentages = NO;
    self.coreDataLayer = [[CoreDataLayer alloc] initWithContext:((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext];
    self.isInFakeStockMode = [self.coreDataLayer isInFakeStockMode];
    self.tableData = @[];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[Globals bebasBook:16]
                                                           forKey:NSFontAttributeName];
    [self.timePeriodPicker setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    [self.timePeriodPicker addTarget:self action:@selector(timePeriodChanged:) forControlEvents:UIControlEventValueChanged];
    [self.timePeriodPicker setSelectedSegmentIndex:0];
    self.priceLabel.font = [Globals bebasLight:40];
    [self checkExchangeOpen];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self changeRealFakeStocks];
    [self checkExchangeOpen];
    [self timePeriodChanged:self.timePeriodPicker];
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if(size.height<size.width && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        NSString *title = @"Pick a stock";
        if(self.stock) title = self.stock.tickerSymbol;
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            if(!self.isChildViewController) self.titleLabel.text = title;
            self.menuButton.alpha = 0;
            self.searchButton.alpha = 0;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            if(!self.isChildViewController) self.titleLabel.text = title;
            self.menuButton.alpha = 0;
            self.searchButton.alpha = 0;
        }];
    }
    else {
        NSString *title = @"My Stocks";
        if(self.isChildViewController) title = @"View Stock";
        if(self.isInPorfolioOverviewMode) title = @"Portfolio Overview";
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.titleLabel.text = title;
            self.menuButton.alpha = 1;
            self.searchButton.alpha = 1;
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.titleLabel.text = title;
            self.menuButton.alpha = 1;
            self.searchButton.alpha = 1;
        }];
    }
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        CGRect frame = self.chartContainer.bounds;
        frame.origin.y += 36;
        frame.size.height -= 36;
        frame.size.width -= 50;
        frame.origin.x += 20;
        for(UIView *view in [[self.chartContainer subviews] mutableCopy]) {
            if([view isKindOfClass:[LCLineChartView class]]) {
                view.frame = frame;
            }
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        CGRect frame = self.chartContainer.bounds;
        frame.origin.y += 36;
        frame.size.height -= 36;
        frame.size.width -= 50;
        frame.origin.x += 20;
        for(UIView *view in [[self.chartContainer subviews] mutableCopy]) {
            if([view isKindOfClass:[LCLineChartView class]]) {
                view.frame = frame;
            }
        }
    }];
    
}

-(void)checkViewControllerStatus
{
    if(self.isChildViewController) {
        [self.menuButton setImage:[UIImage imageNamed:@"x.png"] forState:UIControlStateNormal];
        self.searchButton.alpha = 0;
    }
}

-(void)overviewMode
{
    self.isInPorfolioOverviewMode = YES;
    self.titleLabel.text = @"portfolio";
    
}

-(void)checkExchangeOpen
{
    if(!self.isInFakeStockMode && [Globals isRealExchangeOpen]) self.marketStatusLabel.text = @"market open";
    else if(self.isInFakeStockMode && [Globals isFakeExchangeOpen]) self.marketStatusLabel.text = @"market open";
    else self.marketStatusLabel.text = @"market closed";
    if(self.isInFakeStockMode || self.portfolioView) {
        self.timePeriodPicker.enabled = NO;
        self.timePeriodPicker.alpha = 0.2;
    }
    else {
        self.timePeriodPicker.enabled = YES;
        self.timePeriodPicker.alpha = 1.0;
    }
}

-(void)changeRealFakeStocks
{
    if(!self.isChildViewController) {
        self.stock = nil;
        [self clearAllCharts];
        if(!self.isInFakeStockMode && [self.coreDataLayer getStockObjects].count==0)
            [[DataFetcher dataFetchWithType:DataFetchTypeRealStockList andDelegate:self] fetch];
        else if(self.isInFakeStockMode && [self.coreDataLayer getFakeStockObjects].count==0)
            [[DataFetcher dataFetchWithType:DataFetchTypeFakeStockList andDelegate:self] fetch];
        else {
            [self setTableDataFromCoreData];
        }
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
        
        if(!stock.isFakeStock) cell.tickerSymbolLabel.text = stock.tickerSymbol;
        else cell.tickerSymbolLabel.text = [NSString stringWithFormat:@"~%@",stock.tickerSymbol];
        if(indexPath.row==1 && self.portfolioView) {
            cell.tickerSymbolLabel.text = [NSString stringWithFormat:@"Best: %@",cell.tickerSymbolLabel.text];
            [cell setUserInteractionEnabled:NO];
        }
        else if(indexPath.row==2 && self.portfolioView) {
            cell.tickerSymbolLabel.text = [NSString stringWithFormat:@"Worst: %@",cell.tickerSymbolLabel.text];
            [cell setUserInteractionEnabled:NO];
        }
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
        self.stock = stock;
        ExpandedStockCell *cell = [tableView dequeueReusableCellWithIdentifier:@"expandedCell"];
        if(!stock.isFakeStock) cell.tickerSymbolLabel.text = stock.tickerSymbol;
        else cell.tickerSymbolLabel.text = [NSString stringWithFormat:@"~%@",stock.tickerSymbol];
        if(stock.currentValue && !self.portfolioView) {
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
            [cell.buyButton setUserInteractionEnabled:YES];
            cell.buyButton.alpha = 1;
            if([self.stock.quantityOwned intValue]>0 && !self.portfolioView){
                [cell.sellButton setUserInteractionEnabled:YES];
                cell.sellButton.alpha = 1;
                [cell.buyButton setUserInteractionEnabled:YES];
                cell.buyButton.alpha = 1;
            }
            else if (self.portfolioView) {
                [cell.sellButton setUserInteractionEnabled:YES];
                cell.sellButton.alpha = 1;
                [cell.buyButton setUserInteractionEnabled:YES];
                cell.buyButton.alpha = 1;
            }
            else {
                [cell.sellButton setUserInteractionEnabled:NO];
                cell.sellButton.alpha = 0.2;
                [cell.buyButton setUserInteractionEnabled:YES];
                cell.buyButton.alpha = 1;
            }
            //cell.returnPercentLabel.text = [stock overallPerformancePercent];
        }
        else if(self.portfolioView) {
            cell.currentPriceLabel.text = [NSString stringWithFormat:@"$%@",[Globals numberToString:stock.currentValue]];
            cell.currentPriceLabel.font = [Globals bebasLight:30];
            NSString *performance = [stock dailyPerformanceValuePortfolio];
            if(self.showPercentages) performance = [stock dailyPerformancePercentPortfolio];
            if(performance && [performance rangeOfString:@"-"].location!=NSNotFound)
                cell.performanceButton.backgroundColor = [Globals negativeColor];
            else
                cell.performanceButton.backgroundColor = [Globals positiveColor];
            if(!self.showPercentages) {
                cell.returnPercentDescLabel.text = @"Return Value";
                cell.returnPercentLabel.text = [stock overallPerformanceValuePortfolio];
            }
            else {
                cell.returnPercentDescLabel.text = @"Return Percent";
                cell.returnPercentLabel.text = [stock overallPerformancePercentPortfolio];
            }
            [cell.performanceButton setTitle:performance forState:UIControlStateNormal];
            cell.companyNameLabel.text = stock.companyName;
            cell.coreDataLayer = self.coreDataLayer;
            cell.stock = stock;
            cell.parent = self;
            cell.sharesOwnedLabel.text = [NSString stringWithFormat:@"%d",[stock.quantityOwned intValue]];
            double equityValue = [stock.currentValue doubleValue];
            cell.equityValueLabel.text = [NSString stringWithFormat:@"$%@",[Globals numberToString:[NSNumber numberWithDouble:equityValue]]];
            [cell.sellButton setUserInteractionEnabled:NO];
            cell.sellButton.alpha = 0.2;
            [cell.buyButton setUserInteractionEnabled:NO];
            cell.buyButton.alpha = 0.2;
        }
        else {
            cell.currentPriceLabel.text = @"";
            [cell.buyButton setUserInteractionEnabled:NO];
            cell.buyButton.alpha = 0.2;
            [cell.sellButton setUserInteractionEnabled:NO];
            cell.sellButton.alpha = 0.2;
            //[cell.performanceButton setTitle:@"" forState:UIControlStateNormal];
            cell.stock = self.stock;
            cell.parent = self;
            cell.companyNameLabel.text = self.stock.companyName;
            if(!stock.isFakeStock) cell.tickerSymbolLabel.text = stock.tickerSymbol;
            else cell.tickerSymbolLabel.text = [NSString stringWithFormat:@"~%@",stock.tickerSymbol];
            cell.sharesOwnedLabel.text = [NSString stringWithFormat:@"%d",[stock.quantityOwned intValue]];
            cell.coreDataLayer = nil;
            [cell.buyButton setUserInteractionEnabled:NO];
            [cell.sellButton setUserInteractionEnabled:NO];
            [self.stock downloadCurrentData];
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
    if(self.isChildViewController) {
        return;
    };
    [self clearAllCharts];
    RealStock *stock = (RealStock *)self.tableData[indexPath.row];
    if([self.stock.tickerSymbol isEqualToString:stock.tickerSymbol]) {
        self.stock = nil;
        self.priceLabel.text = @"";
    }
    else {
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
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        if(!self.stock.isFakeStock) [self.stock downloadStockData];
        else [self.stock downloadCurrentData];
    }
    [self.tableView reloadData];
}

-(void)setTableDataFromCoreData
{
    if(!self.isChildViewController) {
        self.chart = nil;
        if(!self.isInFakeStockMode)
            self.tableData = [self.coreDataLayer getOwnedStocksWithDelegate:self];
        else
            self.tableData = [self.coreDataLayer getOwnedFakeStocksWithDelegate:self];
        for(RealStock *stock in self.tableData) {
            [stock downloadCurrentData];
        }
        [self.tableView reloadData];
    }
    else {
        
    }
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
    //self.chart = nil;
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
    if(self.isInFakeStockMode) return;
    [UIView animateWithDuration:0.2 animations:^{
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
        for(RealStock *stock in self.tableData) {
            stock.performanceWindow = window;
            [stock downloadStockData];
        }
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
        [self.coreDataLayer saveFakeStockJSON:dataFetcher.fetchedData];
        [self setTableDataFromCoreData];
    }
}

#pragma mark - RealStockDelegate

-(void)realStockError:(NSError *)error downloadingInformation:(RealStock *)realStock
{
    NSLog(@"%@",error.description);
}

-(void)realStockDoneDownloading:(RealStock *)realStock
{
    if(![realStock.tickerSymbol isEqualToString:self.stock.tickerSymbol] && !self.portfolioView) {
        [self.tableView reloadData];
        return;
    }
    else if(self.portfolioView) {
        NSLog(@"portfolio view");
        RealStock *performance = self.stock;
        performance.currentValue = [NSNumber numberWithDouble:[performance.currentValue doubleValue] + ([realStock.currentValue doubleValue] *(double)[realStock.quantityOwned intValue])];
        performance.totalSpent = [NSNumber numberWithDouble:[performance.totalSpent doubleValue] + [realStock.totalSpent doubleValue]];
        ((PriceTime *)performance.performanceValues[0]).price = performance.currentValue;
        if(self.tableData.count==1) self.tableData = @[self.tableData[0], realStock];
        else if(self.tableData.count==2) {
            double real = ([realStock.currentValue doubleValue] *((double)[realStock.quantityOwned intValue]))-[realStock.totalSpent doubleValue];
            RealStock *inList = self.tableData[1];
            double first = ([inList.currentValue doubleValue] *((double)[inList.quantityOwned intValue]))-[inList.totalSpent doubleValue];
            if(first>real) self.tableData = @[self.tableData[0], inList, realStock];
            else self.tableData = @[self.tableData[0], realStock, inList];
        }
        else {
            double real = ([realStock.currentValue doubleValue] *((double)[realStock.quantityOwned intValue]))-[realStock.totalSpent doubleValue];
            RealStock *pos1 = self.tableData[1];
            double first = ([pos1.currentValue doubleValue] *((double)[pos1.quantityOwned intValue]))-[pos1.totalSpent doubleValue];
            RealStock *pos2 = self.tableData[2];
            double second = ([pos2.currentValue doubleValue] *((double)[pos2.quantityOwned intValue]))-[pos2.totalSpent doubleValue];
            if(real>first) self.tableData = @[self.tableData[0], realStock, pos2];
            else if (real<second) self.tableData = @[self.tableData[0], pos1, realStock];
        }
        [self.tableView reloadData];
        return;
    }
    [self clearAllCharts];
    self.chart = [[CFStockChart alloc] initWithStock:realStock];
    self.chart.priceLabel = self.priceLabel;
    self.chart.chart.alpha = 0;
    CGRect frame = self.chartContainer.bounds;
    frame.origin.y += 36;
    frame.size.height -= 36;
    frame.size.width -= 50;
    frame.origin.x += 20;
    self.chart.chart.frame = frame;
    [self.chartContainer addSubview:self.chart.chart];
    [UIView animateWithDuration:0.2 animations:^{
        self.chart.chart.alpha = 1;
    }];
    self.priceLabel.text = [NSString stringWithFormat:@"$%@",[Globals numberToString:self.stock.currentValue]];
    NSString *test = [realStock peformanceToJSON];
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
    vc.coreDataLayer = self.coreDataLayer;
    vc.parent = self;
    vc.isInFakeStockMode = [self.coreDataLayer isInFakeStockMode];
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
    vc.isInFakeStockMode = self.isInFakeStockMode;
    [vc loadData];
    [UIView animateWithDuration:0.4 animations:^{
        vc.view.alpha = 1;
    } completion:^(BOOL finished) {
        vc.view.alpha = 1;
    }];
}


@end
