//
//  DetailCompliteController.h
//  Trading agent
//
//  Created by  Yury_apple_mini on 4/5/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "ViewController.h"

@interface DetailCompliteController : PFQueryTableViewController

@property (nonatomic, weak) UILabel *sumLabel;
@property (nonatomic, strong ) NSString *numberOrder;

@end
