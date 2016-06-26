//
//  ViewController.h
//  Trading agent
//
//  Created by  Yury_apple_mini on 4/6/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "DetailCompliteController.h"


@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *orderHeder;
@property (weak, nonatomic) IBOutlet UILabel *dateOrder;
@property (weak, nonatomic) IBOutlet UILabel *dateComp;

@property (weak, nonatomic) IBOutlet UILabel *sumLabel;


@property (nonatomic, strong ) NSString *numberOrder;
@property (nonatomic, strong ) NSString *dateCreateOrder;
@property (nonatomic, strong ) NSString *dateCompiteOrder;

@end
