//
//  ExecuteOrderController.h
//  Trading agent
//
//  Created by  Yury_apple_mini on 4/13/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <CoreData/CoreData.h>
#import "SharedManagedObjectContext.h"
#import "SliderForFooter.h"
#import "SharedSettingsUserDefault.h"



@interface ExecuteOrderController : PFQueryTableViewController

/*! @brief This property is  Managed Object Context from Core Data. */
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


/*! @brief Object for access to the settings from "Settings.bundle". */
@property (strong, nonatomic) SharedSettingsUserDefault *settingsUserDefault;

@end
