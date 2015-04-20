//
//  StockCell.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/18/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StockCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *tickerSymbolLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (strong, nonatomic) IBOutlet UIButton *performanceButton;


@end
