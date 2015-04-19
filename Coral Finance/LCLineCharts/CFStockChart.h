//
//  CFStockChart.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/9/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "LCLineChartView.h"
#import "RealStock.h"
#import "Globals.h"

@interface CFStockChart : LCLineChartView <UIGestureRecognizerDelegate>

@property (strong, nonatomic) LCLineChartView *chart;
@property (strong, nonatomic) RealStock *stock;
@property (strong, nonatomic) UILabel *priceLabel;

-(id)initWithStock:(RealStock *)stock;

@end
