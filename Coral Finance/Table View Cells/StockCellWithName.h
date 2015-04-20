//
//  StockCellWithName.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/19/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StockCellWithName : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *tickerSymbolLabel;
@property (strong, nonatomic) IBOutlet UILabel *companyNameLabel;

@end
