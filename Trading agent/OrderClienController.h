//
//  OrderClienController.h
//  Trading agent
//
//  Created by  Yury_apple_mini on 3/28/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConvertProducts.h"
#import "SharedManagedObjectContext.h"
#import "SharedSettingsUserDefault.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


@interface OrderClienController : UITableViewController <ConvertProductsDelegate ,NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) SharedSettingsUserDefault *settingsUserDefault;
@property (nonatomic, strong ) NSString *numberOrder;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *add;

- (IBAction)cancelButton:(UIBarButtonItem *)sender;
- (IBAction)saveButton:(UIBarButtonItem *)sender;

@end
