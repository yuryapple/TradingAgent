//
//  MasterAddresBookController.m
//  Trading agent
//
//  Created by  Yury_apple_mini on 3/15/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "MasterAddresBookController.h"
#import "SharedManagedObjectContext.h"
#import "SharedSettingsUserDefault.h"
#import <CoreData/CoreData.h>
#import "OrderClienController.h"

@interface MasterAddresBookController ()

@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (assign) BOOL  didChangeNotification;



-(void)showAddressBook;
-(void)insertNewClientAddress:(NSMutableDictionary *)contactInfoDict withClientID: (NSString *) uuid;
-(NSIndexPath *)addOrEditClient: (NSMutableDictionary *)contactInfoDict;
-(NSString *)getClientUUID:(NSIndexPath *)indexExistClient;
@end




@implementation MasterAddresBookController


- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        _managedObjectContext =[[SharedManagedObjectContext sharedManager] managedObjectContext] ;
        _settingsUserDefault =[SharedSettingsUserDefault sharedSettingsUserDefault] ;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableWithCurrentSettings)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.title = [[NSString stringWithFormat:@"%@ - ", NSLocalizedString([_settingsUserDefault getDefaultNameDeliveryPerson], nil)] stringByAppendingString:NSLocalizedString(@"Delivery", nil)];
    
    [self.tabBarController.tabBar.items objectAtIndex:1].enabled = NO;
    [self.tabBarController.tabBar.items objectAtIndex:2].enabled = NO;
    
      self.didChangeNotification = NO;
    
    
    
/*

    NSFetchRequest *request1 = [NSFetchRequest fetchRequestWithEntityName:@"Client"];
    NSArray *result1 = [[self managedObjectContext] executeFetchRequest:request1 error:nil];

    for (id basket in result1){
        
      //  NSDate *currentDate = [NSDate date];
       // NSDate *dateAgo = [currentDate dateByAddingTimeInterval:(- 100 * 24 * 60 * 60)];
        
     
        //[basket setValue:[basket valueForKey:@"updateAt"] forKey:@"createAt"];
        [_managedObjectContext deleteObject:basket];
     
        [[SharedManagedObjectContext sharedManager] saveContext];
    }
*/

    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:nil];
    
  
    /* delete all old
    int i =0;
    for (id basket in result){
        [_managedObjectContext deleteObject:basket];
        NSLog(@"Delete from order %d" , i++);
    }
    
    [[SharedManagedObjectContext sharedManager] saveContext];
    
    */
    
    
   if (result.count) {
        NSManagedObject *currentOrder   = [result objectAtIndex:0];
       [self performSegueWithIdentifier:@"compliteInterraptOrder" sender:[currentOrder valueForKey:@"numberOrder"]];
    }
}


-(void)viewWillAppear:(BOOL)animated {
  [self updateNavigationButtons];
}




-(void)reloadTableWithCurrentSettings {
    self.didChangeNotification = YES;
    [self.tableView reloadData];
    [self updateNavigationButtons];
}



-(void)convertCoreDataToParse {
 //   NSLog(@"Convert to Parse %@", orderNumber);

    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Client"];
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:nil];
    
    // add client to Parse (Export)
    
     for (id client in result){
         
  
         PFObject *clientParse;
         
         
         clientParse = [PFObject objectWithClassName:@"Clients"];
         
         clientParse[@"clientID"] = [client valueForKey:@"clientID"];
         clientParse[@"firstName"] = [client valueForKey:@"firstName"];
         clientParse[@"mobileSecond"] = [client valueForKey:@"homeNumber"];
         clientParse[@"lastName"] = [client valueForKey:@"lastName"];
         clientParse[@"mobileFirst"] = [client valueForKey:@"mobileNumber"];
         clientParse[@"OwnerAddressBook"] = @([_settingsUserDefault getDefaultOwnerNumber]);
         
         [clientParse saveInBackground];
         
    }
         
         
      //   clientParse[@"numberOrder"] = @([orderNumber integerValue]);
      //   clientParse[@"clientID"] = clientID;
      //   clientParse[@"dateOrder"] = [NSDate date];
 
         
         
         
//     [_managedObjectContext deleteObject:basket];
//     NSLog(@"Delete from order %d" , i++);
         
         
   
     
    // [[SharedManagedObjectContext sharedManager] saveContext];
    

        
    
        

}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)add:(id)sender
{
    [self showAddressBook];
}

- (IBAction)exportOrSynsButton:(id)sender {
    if (self.actionSynsOrExportForButton == nothingDoIt) {
       
    } else if (self.actionSynsOrExportForButton == synsDoIt) {
        for (PFObject *recordFromParse in self.diffRecordsFromParse) {
    
            NSLog(@"exportOrSynsButton %@", [self convertPFObjectToNSMutableDictionary: recordFromParse]);
            
            NSMutableDictionary *contactInfoDict =[self convertPFObjectToNSMutableDictionary: recordFromParse];

            NSLog(@"                 %@", contactInfoDict);
            
            NSIndexPath *indexExistClient  = [self addOrEditClient: contactInfoDict];
            
            [self editExistClientInParse:contactInfoDict withIndex:indexExistClient];
        }
    } else if (self.actionSynsOrExportForButton == exportDoIt) {
        for (PFObject *recordFromParse in self.diffRecordsFromParse) {
          //  NSLog(@"exportOrSynsButton %@", [self convertPFObjectToNSMutableDictionary: recordFromParse]);
            NSMutableDictionary *contactInfoDict =[self convertPFObjectToNSMutableDictionary: recordFromParse];
            NSLog(@"                 %@", contactInfoDict);
            NSIndexPath *indexExistClient  = [self addOrEditClient: contactInfoDict];
            if (indexExistClient) {
                [self editExistClientInParse:contactInfoDict withIndex:indexExistClient];
            } else {
                [self insertNewClientAddress:contactInfoDict withClientID:[contactInfoDict valueForKey:@"clientID" ]];
            }
        }

    }
    
      [self updateNavigationButtons];
      [self.tableView reloadData];
}



-(void)showAddressBook
{
    _addressBookController = [[ABPeoplePickerNavigationController alloc] init];
    [_addressBookController setPeoplePickerDelegate:self];
    [self presentViewController:_addressBookController animated:YES completion:nil];
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
  
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}



- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"indexPath  %@", indexPath);
    
    
    
    
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *fullName =[NSString stringWithFormat:@"%@ %@", [[object valueForKey:@"firstName"] description] , [[object valueForKey:@"lastName"] description]];
    
    cell.textLabel.text = fullName;
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:sender]];
        
        NSArray *keys = [[[object entity] attributesByName] allKeys];
        NSDictionary *contactDetailsDictionary = [object dictionaryWithValuesForKeys:keys];
     
       [[segue destinationViewController] setDictContactDetails :contactDetailsDictionary];
    }
    
    if ([[segue identifier] isEqualToString:@"compliteInterraptOrder"]) {
        
        
        OrderClienController *controller = (OrderClienController *)[[segue destinationViewController] topViewController];
        
        NSLog(@" setNumberOrder %@  ", sender);
        
        [controller setNumberOrder :[NSString stringWithFormat:@"%@", sender]];
        
        
     
        
   
    }
}



#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil  && self.didChangeNotification != YES) {
        return _fetchedResultsController;
    }
    
    
    // Clear previous cache
    [NSFetchedResultsController deleteCacheWithName:@"ClientAddress"];
    
    self.didChangeNotification = NO;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Client" inManagedObjectContext:self.managedObjectContext];
    
    
    NSLog(@"owner == %ld",
          (long)[_settingsUserDefault getDefaultOwnerNumber]);
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:   @"owner == %d",
                              [[NSString stringWithFormat:@"%ld",(long)[_settingsUserDefault getDefaultOwnerNumber]] integerValue]
                              ];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:predicate];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"ClientAddress"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}



- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}



- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}




#pragma mark - Addres Book People Navigation  Controller

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
}


- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
    NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc]
                                            initWithObjects:@[@"", @"", @"", @""]
                                            forKeys:@[@"firstName", @"lastName", @"mobileNumber", @"homeNumber"]];
    
    
    CFTypeRef generalCFObject;
    
    generalCFObject = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"firstName"];
        CFRelease(generalCFObject);
    }
    
    
    
    generalCFObject = ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (generalCFObject) {
        [contactInfoDict setObject:(__bridge NSString *)generalCFObject forKey:@"lastName"];
        CFRelease(generalCFObject);
    }
    
    
    
    ABMultiValueRef phonesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++)
    {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
        }
        
        if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"homeNumber"];
        }
        
        CFRelease(currentPhoneLabel);
        CFRelease(currentPhoneValue);
    }
    CFRelease(phonesRef);
    
    
    // Add new contact to Core Data
    [self addOrReplaseClientInParse:(NSMutableDictionary *)contactInfoDict];
    
    [self.tableView reloadData];
    
    [_addressBookController dismissViewControllerAnimated:YES completion:nil];
    
    
}




#pragma mark - Add or replase a client in Parse
-(void)addOrReplaseClientInParse:(NSMutableDictionary *)contactInfoDict
{
    NSIndexPath *indexExistClient = [self addOrEditClient:contactInfoDict];
   
    if(indexExistClient){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"clientID == %@", [self getClientUUID:indexExistClient]];
        
        NSLog(@"clientID == %@", [self getClientUUID:indexExistClient]);
        
        PFQuery *query = [PFQuery queryWithClassName:@"Clients" predicate:predicate];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable clientParse, NSError * _Nullable error) {
            if (!error){
                clientParse[@"mobileSecond"] = [contactInfoDict objectForKey:@"mobileNumber"];
                clientParse[@"lastName"] = [contactInfoDict objectForKey:@"lastName"];
                clientParse[@"mobileFirst"] = [contactInfoDict objectForKey:@"homeNumber"];
                
                [clientParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        [contactInfoDict setValue:[clientParse updatedAt] forKey:@"updateAt"];
                        [self editExistClientInParse: contactInfoDict withIndex: indexExistClient];
                    }else{
                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);            }
                    }];
            }else{
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);            }
        }];

        
    }else{
        // New Client
        
        // Generate UUID
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        NSString *uuid = (__bridge NSString *)string;
        
        
        PFObject *clientParse;
        clientParse = [PFObject objectWithClassName:@"Clients"];
        
        clientParse[@"clientID"] = uuid;
        clientParse[@"firstName"] = [contactInfoDict objectForKey:@"firstName"];
        clientParse[@"mobileSecond"] = [contactInfoDict objectForKey:@"mobileNumber"];
        clientParse[@"lastName"] = [contactInfoDict objectForKey:@"lastName"];
        clientParse[@"mobileFirst"] = [contactInfoDict objectForKey:@"homeNumber"];
        
        clientParse[@"OwnerAddressBook"] = @([_settingsUserDefault getDefaultOwnerNumber]);
        
        [clientParse saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [contactInfoDict setValue:[clientParse createdAt] forKey:@"createAt"];
                [contactInfoDict setValue:[clientParse updatedAt] forKey:@"updateAt"];
                [self insertNewClientAddress:contactInfoDict withClientID:uuid];
            }else{
             NSLog(@"Unresolved error %@, %@", error, [error userInfo]);            }
        }];
    }
}







#pragma mark - Core Data 


- (void)insertNewClientAddress:(NSMutableDictionary *)contactInfoDict withClientID: (NSString *) uuid  {
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [newManagedObject setValue:[contactInfoDict objectForKey:@"firstName"] forKey:@"firstName"];
    [newManagedObject setValue:[contactInfoDict objectForKey:@"lastName"] forKey:@"lastName"];
    [newManagedObject setValue:[contactInfoDict objectForKey:@"mobileNumber"] forKey:@"mobileNumber"];
    [newManagedObject setValue:[contactInfoDict objectForKey:@"homeNumber"] forKey:@"homeNumber"];
    [newManagedObject setValue:uuid forKey:@"clientID"];
    
    [newManagedObject setValue:[contactInfoDict objectForKey:@"createAt"] forKey:@"createAt"];
    [newManagedObject setValue:[contactInfoDict objectForKey:@"updateAt"] forKey:@"updateAt"];
    [newManagedObject setValue:[contactInfoDict objectForKey:@"OwnerAddressBook"] forKey:@"owner"];
  
    
    [[SharedManagedObjectContext sharedManager] saveContext];
}


-(void)editExistClientInParse:(NSMutableDictionary *) contactInfoDict withIndex: (NSIndexPath *) indexExistClient {
    NSManagedObject *client = [_fetchedResultsController objectAtIndexPath:indexExistClient];
    [client setValue:[contactInfoDict objectForKey:@"lastName"] forKey:@"lastName"];
    [client setValue:[contactInfoDict objectForKey:@"mobileNumber"] forKey:@"mobileNumber"];
    [client setValue:[contactInfoDict objectForKey:@"homeNumber"] forKey:@"homeNumber"];
    [client setValue:[contactInfoDict objectForKey:@"updateAt"] forKey:@"updateAt"];
    [client setValue:[contactInfoDict objectForKey:@"OwnerAddressBook"] forKey:@"owner"];
    
    [[SharedManagedObjectContext sharedManager] saveContext];
}

-(NSString *)getClientUUID:(NSIndexPath *) indexExistClient{
    NSManagedObject *client = [_fetchedResultsController objectAtIndexPath:indexExistClient];
    return [client valueForKey:@"clientID"];
}



/*
- (void)insertNewClientAddress:(NSMutableDictionary *)contactInfoDict
{
    NSIndexPath *indexExistClient = [self AddOrEditClient:contactInfoDict];
    
    if (indexExistClient){
        NSManagedObject *client = [_fetchedResultsController objectAtIndexPath:indexExistClient];
        [client setValue:[contactInfoDict objectForKey:@"lastName"] forKey:@"lastName"];
        [client setValue:[contactInfoDict objectForKey:@"mobileNumber"] forKey:@"mobileNumber"];
        [[SharedManagedObjectContext sharedManager] saveContext];
    } else {
        // Create a new instance of the entity managed by the fetched results controller.
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];

        [newManagedObject setValue:[contactInfoDict objectForKey:@"firstName"] forKey:@"firstName"];
        [newManagedObject setValue:[contactInfoDict objectForKey:@"lastName"] forKey:@"lastName"];
        [newManagedObject setValue:[contactInfoDict objectForKey:@"mobileNumber"] forKey:@"mobileNumber"];
        [newManagedObject setValue:[contactInfoDict objectForKey:@"homeNumber"] forKey:@"homeNumber"];
    
        // Generate UUID
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        NSString *uuid = (__bridge NSString *)string;
        [newManagedObject setValue:uuid forKey:@"clientID"];
    

        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
        }
    }
}

*/

-(NSIndexPath *)addOrEditClient: (NSMutableDictionary *)contactInfoDict {
    NSIndexPath *path = nil;
    for (id object in [self.fetchedResultsController fetchedObjects]){
        
        if ( [object valueForKey:@"firstName"] == [contactInfoDict objectForKey:@"firstName"] &&
            ([object valueForKey:@"lastName"] ==  [contactInfoDict objectForKey:@"lastName"] ||
             [object valueForKey:@"homeNumber"] ==  [contactInfoDict objectForKey:@"homeNumber"] ||
             [object valueForKey:@"mobileNumber"] ==  [contactInfoDict objectForKey:@"mobileNumber"]) )
        {
            // Client of indexPath for edit (Edit her last name or  mobile number)
            path = [_fetchedResultsController indexPathForObject:object];
            return path;
        }
    }
    return path;
}

@end
