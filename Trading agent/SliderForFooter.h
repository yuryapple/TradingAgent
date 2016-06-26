//
//  MySlider.h
//  SliderTable
//
//  Created by  Yury_apple_mini on 4/2/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompliteOrderController.h"

@interface SliderForFooter : UIViewController

@property (nonatomic, assign)  int  section;
@property (nonatomic, assign)  int  days;
@property (nonatomic, weak)  UITableViewController * delegate;
@property (nonatomic, weak) IBOutlet UILabel *label;


- (IBAction)ShowValue:(id)sender;


@end
