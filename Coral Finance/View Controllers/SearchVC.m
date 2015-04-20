//
//  SearchVC.m
//  Coral Finance
//
//  Created by Kyle Shaver on 4/19/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "SearchVC.h"
#import "PortfolioVC.h"

@interface SearchVC ()

@end

@implementation SearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSFontAttributeName: [Globals bebasRegular:26.0]}];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class] , nil] setTextColor:[UIColor whiteColor]];
    NSArray *jsonDictionary = [self.coreDataLayer getRealStockJSON];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in jsonDictionary) {
        RealStock *stock =[[RealStock alloc] initWithTicker:[dict valueForKey:@"symbol"] performanceWindow:PerformanceWindowOneDay andDelegate:nil];
        stock.companyName = [dict valueForKey:@"name"];
        [array addObject:stock];
    }
    self.rawArray = array;
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.searchBar.text isEqualToString:@""]) return 0;
    return self.tableData.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.searchBar resignFirstResponder];
    RealStock* stock = self.tableData[indexPath.row];
    PortfolioVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"home"];
    [self addChildViewController:vc];
    vc.view.alpha = 0;
    [self.view addSubview:vc.view];
    [UIView animateWithDuration:0.4 animations:^{
        self.view.alpha = 1;
        vc.view.alpha = 1;
    } completion:^(BOOL finished) {
        vc.view.alpha = 1;
        self.view.alpha = 1;
    }];
    vc.isChildViewController = YES;
    [vc checkViewControllerStatus];
    [vc.tableView setUserInteractionEnabled:YES];
    [vc.tableView setScrollEnabled:NO];
    vc.tableData = @[stock];
    vc.stock = stock;
    stock.delegate = vc;
    vc.didCheckOwned = NO;
    [stock downloadCurrentData];
    [vc setTableDataFromCoreData];
    vc.titleLabel.text = @"View Stock";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RealStock *stock = (RealStock *)self.tableData[indexPath.row];
    StockCellWithName *cell = [tableView dequeueReusableCellWithIdentifier:@"stockCell"];
    cell.tickerSymbolLabel.text = stock.tickerSymbol;
    cell.companyNameLabel.text = stock.companyName;
    cell.selectedBackgroundView = [UIView new];
    cell.selectedBackgroundView.backgroundColor = [Globals backgroundColor];
    return cell;
}

#pragma mark - UISearchBar

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText isEqualToString:@""]) {
        self.tableData = nil;
    }
    else {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(RealStock *realStock in self.rawArray) {
            if([[realStock.tickerSymbol lowercaseString] containsString:[searchText lowercaseString]] || [[realStock.companyName lowercaseString] containsString:[searchText lowercaseString]]) {
                [array addObject:realStock];
            }
        }
        self.tableData = array;
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tickerSymbol"
                                                     ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.tableData = [self.tableData sortedArrayUsingDescriptors:sortDescriptors];
        [self.tableView reloadData];
    }
}

-(IBAction)close:(id)sender
{
    [UIView animateWithDuration:0.4 animations:^{
        self.view.alpha = 0;
        [((PortfolioVC *)self.parentViewController) setTableDataFromCoreData];
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
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
