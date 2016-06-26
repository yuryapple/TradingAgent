//
//  FoodList.h
//  FoofList
//
//  Created by  Yury_apple_mini on 3/21/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "SharedManagedObjectContext.h"
#import "SharedSettingsUserDefault.h"



@interface FoodListController : PFQueryTableViewController
@property (nonatomic, weak)  NSString *numberOrder;
@property (nonatomic, strong ) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) SharedSettingsUserDefault *settingsUserDefault;
@property (nonatomic, strong) NSMutableArray *productsExistInOrder;

@end
