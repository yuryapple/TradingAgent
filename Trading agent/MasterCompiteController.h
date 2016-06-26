//
//  MasterCompiteController.h
//  Trading agent
//
//  Created by  Yury_apple_mini on 4/2/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MasterCompiteController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tdCompOrder;

@end
