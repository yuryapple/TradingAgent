//
//  MasterAddresBookController.h
//  Delivery Person
//
//  Created by  Yury_apple_mini on 3/15/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>

#import "AppDelegate.h"
#import "DetailAddressBookController.h"
#import "SharedManagedObjectContext.h"
#import "SharedSettingsUserDefault.h"

/*!
 @typedef visibleSynsOrExportButton
 
 @brief  An emumeration about the visibility buttons.
 
 @discussion
 In navigation bar show picture Import or Syns button.
 
 @constant visibleSynsButton    Show syns button.
 @constant visibleExportButton  Show import button.

 */
typedef enum sibleSynsOrExportButtonTypes
{
    /*! Show syns button */
    visibleSynsButton,
    /*! Show import button */
    visibleExportButton
} visibleSynsOrExportButton;



/*!
 @typedef ActionSynsOrExport
 
 @brief  An emumeration about the visibility button.
 
 @discussion
What kind of type action needs run.
 
 @constant nothingDoIt r
 @constant synsDoIt  Syns records Parse and Cora Data
 @constant exportDoIt    Import recorsd from Parse

 */
typedef enum actionSynsOrExportTypes
{
    nothingDoIt,
    synsDoIt,
    exportDoIt
} actionSynsOrExport;



@interface MasterAddresBookController : UITableViewController <NSFetchedResultsControllerDelegate , ABPeoplePickerNavigationControllerDelegate>

/*! @brief This property is  Managed Object Context from Core Data. */
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

/*! @brief This property is enum  of  "actionSynsOrExport" and stored type's action .  */
@property (assign, nonatomic) actionSynsOrExport  actionSynsOrExportForButton;

/*! @brief This property is array that consist from records of Parse server  which is newly than records from Core Data. */
@property (strong, nonatomic) NSArray *diffRecordsFromParse;

/*! @brief Object for access to the settings from "Settings.bundle". */
@property (strong, nonatomic) SharedSettingsUserDefault *settingsUserDefault;


/*!
 @brief This IBAction add new information about client from Address Book  to CoreDate and Parse server .
 
 @param  sender.
 
 @return void.
 */
- (IBAction)add:(id)sender;




/*!
 @brief This IBAction syns or imports information about clients from Parse server to Core Data
 
 @param  sender.
 
 @return void.
 */
- (IBAction)exportOrSynsButton:(id)sender;

@end


@interface MasterAddresBookController (ExportOrSynchronizeAddressBookForOwners)
/*!
 @brief It gets array of clients from Core Data for for a particular delivery person. This array will be compared with array from Parse server.
 
 @param  empty.
 
 @return Array of clients from Cora Data.
 */
-(NSArray *) recordsInCoreData;

/*!
@brief It gets array of clients from Parse server for  a particular delivery person. This array will be compared with array from Core Data.

@param  empty.

@return void.
*/
-(void) recordsInParse;


/*!
 @brief Enable or disable byttons on navigation bar.
 
 @param  visibleSynsOrExpor Import or syns button is visible on nav bar.
 @param        enableSynsOrExpor Is bool value. Is button enanle on navigation bar?
 @param        enableAddClient Is bool valueIs. Is button enanle on navigation bar?

 @return void.
 */
-(void)visibleSynsOrExportButton:(visibleSynsOrExportButton)visibleSynsOrExpor EnableSynsOrExportButton:(BOOL)enableSynsOrExpor EnanleAddClientButton:(BOOL) enableAddClient;

/*!
 @brief It converts PFObject to NSMutableDictionary for further processing, because Core Date don't works with PFObject.
 
 @param  PFObject (infotmation from Parse server).
 
 @return NSMutableDictionary contains all information about a client. This information will be pass to  add or edit client.
 */
-(NSMutableDictionary *)convertPFObjectToNSMutableDictionary:(PFObject *) recordFromParse;


/*!
 @brief It updates navigation buttons, based on the difference both array from Parse and Core Date.
 This metod based on  "Facade Pattern".
 
 @param  empty.
 
 @return void.
 */
-(void)updateNavigationButtons;

@end