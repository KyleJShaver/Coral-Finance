//
//  CFStockChart.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/9/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import "LCLineChartView.h"
#import "RealStock.h"

@interface CFStockChart : LCLineChartView

@property (strong, nonatomic) LCLineChartView *chart;
@property (strong, nonatomic) RealStock *stock;

-(id)initWithStock:(RealStock *)stock;

@end
