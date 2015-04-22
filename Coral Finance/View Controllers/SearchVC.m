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
    self.rawArray = [self.coreDataLayer getStockObjects];
    [self.tableView reloadData];
    //[self registerForKeyboardNotifications];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard Stuff

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, -kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
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
    RealStock* stock = [RealStock stockWithCoreStockObject:self.tableData[indexPath.row] andDelegate:nil];
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
    [vc setTableDataFromCoreData];
    vc.titleLabel.text = @"view stock";
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
        [self.tableView reloadData];
    }
    else {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for(CoreStockObject *realStock in self.rawArray) {
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
