//
//  DetailAddressBookController.h
//  Delivery Person
//
//  Created by  Yury_apple_mini on 3/16/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedManagedObjectContext.h"
#import "SharedSettingsUserDefault.h"

@interface DetailAddressBookController : UIViewController


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/*! @brief Object for access to the settings from "Settings.bundle". */
@property (strong, nonatomic) SharedSettingsUserDefault *settingsUserDefault;

@property (nonatomic , strong)  NSDictionary *dictContactDetails;
@property (weak, nonatomic) IBOutlet UITextField *fieldFirstName;
@property (weak, nonatomic) IBOutlet UITextField *fieldLastName;
@property (weak, nonatomic) IBOutlet UITextField *fieldMobilePhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *fieldHomePhoneNumber;

- (IBAction)callMobilePhoneNumber:(id)sender;
- (IBAction)callHomePhoneNumber:(id)sender;
- (IBAction)newOrder:(id)sender;


@end
