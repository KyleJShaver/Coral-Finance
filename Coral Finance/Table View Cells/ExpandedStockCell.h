//
//  ExpandedStockCell.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/18/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpandedStockCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *tickerSymbolLabel;
@property (strong, nonatomic) IBOutlet UILabel *companyNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *sharesOwnedLabel;
@property (strong, nonatomic) IBOutlet UILabel *equityValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *returnPercentLabel;
@property (strong, nonatomic) IBOutlet UIButton *performanceButton;
@property (strong, nonatomic) IBOutlet UIButton *buyButton;
@property (strong, nonatomic) IBOutlet UIButton *sellButton;

@end
