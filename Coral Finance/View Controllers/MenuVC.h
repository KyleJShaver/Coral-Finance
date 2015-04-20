//
//  MenuVC.h
//  Coral Finance
//
//  Created by Kyle Shaver on 4/19/15.
//  Copyright (c) 2015 Team Wireframe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"

@interface MenuVC : UIViewController

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

-(IBAction)close:(id)sender;

@end
