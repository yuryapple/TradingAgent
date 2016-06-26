//
//  ViewController.m
//  Trading agent
//
//  Created by  Yury_apple_mini on 4/6/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _orderHeder.text = [_orderHeder.text stringByAppendingString: _numberOrder] ;
    _dateOrder.text = [_dateOrder.text stringByAppendingString: _dateCreateOrder];
    _dateComp.text = [_dateComp.text stringByAppendingString: _dateCompiteOrder ];
    
 
    DetailCompliteController *detailController = [self.childViewControllers objectAtIndex:0];
    detailController.sumLabel = _sumLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ViewController *controller = [segue destinationViewController];
    [controller setNumberOrder : _numberOrder];
}

@end
