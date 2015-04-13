//
//  LCInfoView.h
//  Classes
//
//  Created by Marcel Ruegenberg on 19.11.09.
//  Copyright 2009-2011 Dustlab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCInfoView : UIView

@property CGPoint tapPoint;

@property (strong) UILabel *infoLabel;


@property (strong, nonatomic) UIColor *bgColor;
@property (strong, nonatomic) UIColor *textColor;

@end
