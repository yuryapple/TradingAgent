//
//  MasterAddresBookController+ExportOrSynchronizeAddressBookForOwners.m
//  Trading agent
//
//  Created by  Yury_apple_mini on 5/11/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//


#import "MasterAddresBookController.h"
#import <Parse/Parse.h>

@implementation MasterAddresBookController (ExportOrSynchronizeAddressBookForOwners)

-(void)updateNavigationButtons {
    [self recordsInParse];
}


-(NSArray *) recordsInCoreData{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"owner == %d", [self.settingsUserDefault getDefaultOwnerNumber]];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Client"];
    [request setPredicate:predicate];
    
  //  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updateAt" ascending:YES];
    
   // [request setSortDescriptors:@[sortDescriptor]];
    
    
    NSError *error = nil;
    
    NSArray *recInCore = [[self managedObjectContext] executeFetchRequest:request error:&error];
     NSLog(@"Error fetching Employee objects: %@\n%@", [error localizedDescription], [error userInfo]);
    
    return recInCore;
}


-(void) recordsInParse{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"OwnerAddressBook == %d", [self.settingsUserDefault getDefaultOwnerNumber]];
    PFQuery *query = [PFQuery queryWithClassName:@"Clients" predicate:predicate];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * objectsParse, NSError * error) {
        [self compareRecordsFromCore:[self recordsInCoreData] AndParse:objectsParse];
    }];
}


-(void)compareRecordsFromCore:(NSArray *) recCore AndParse:(NSArray *)recParse{
    self.diffRecordsFromParse = [NSArray array];
    
    if([recCore count] == 0 && [recParse count] == 0) {
        [self visibleSynsOrExportButton: visibleExportButton EnableSynsOrExportButton:NO EnanleAddClientButton:YES];
        self.actionSynsOrExportForButton = nothingDoIt;
    } else if ([recCore count] == [recParse count]  && (![[recCore valueForKeyPath:@"@max.updateAt"] isEqualToDate:[[recParse objectAtIndex:0] updatedAt]])){

        NSDate *coreDateMax = [recCore valueForKeyPath:@"@max.updateAt"];
        self.diffRecordsFromParse = [self getDiffRecordsFromParse:(NSArray *)recParse  withCoreDataMaxDate:(NSDate *)coreDateMax];
        [self visibleSynsOrExportButton:visibleSynsButton EnableSynsOrExportButton: YES EnanleAddClientButton:NO];
        self.actionSynsOrExportForButton = synsDoIt;
    }else if ([recCore count] == [recParse count]){
        [self visibleSynsOrExportButton:visibleExportButton EnableSynsOrExportButton: NO EnanleAddClientButton:YES];
        self.actionSynsOrExportForButton = nothingDoIt;
    } else{
        NSDate *coreDateMax = [recCore valueForKeyPath:@"@max.updateAt"];
        
        self.diffRecordsFromParse = [self getDiffRecordsFromParse:(NSArray *)recParse  withCoreDataMaxDate:(NSDate *)coreDateMax];
        [self visibleSynsOrExportButton: visibleExportButton EnableSynsOrExportButton:YES EnanleAddClientButton:NO];
        self.actionSynsOrExportForButton = exportDoIt;
    }
}


-(void)visibleSynsOrExportButton:(visibleSynsOrExportButton) visibleSynsOrExpor EnableSynsOrExportButton:(BOOL)enableSynsOrExpor EnanleAddClientButton:(BOOL) enableAddClient {
    
    self.navigationItem.title = [[NSString stringWithFormat:@"%@ - ", NSLocalizedString([self.settingsUserDefault getDefaultNameDeliveryPerson], nil)] stringByAppendingString:NSLocalizedString(@"Delivery", nil)];
    
    
    if (self.actionSynsOrExportForButton == exportDoIt) {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"Import.png"];
    } else {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"Synchronize.png"];
    }
    
    
    if (self.actionSynsOrExportForButton == exportDoIt && enableSynsOrExpor == YES) {
        [self.tabBarController.tabBar.items objectAtIndex:1].enabled = NO;
        [self.tabBarController.tabBar.items objectAtIndex:2].enabled = NO;
    } else {
        [self.tabBarController.tabBar.items objectAtIndex:1].enabled = YES;
        [self.tabBarController.tabBar.items objectAtIndex:2].enabled = YES;
    }
    
    self.navigationItem.leftBarButtonItem.enabled = enableSynsOrExpor;
    self.navigationItem.rightBarButtonItem.enabled = enableAddClient;
}


-(NSArray *)getDiffRecordsFromParse:(NSArray *)recParse  withCoreDataMaxDate:(NSDate *)coreDateMax{
    
      NSLog(@"coreDateMax %@ ",coreDateMax);
    
    if (!coreDateMax) {
       // [coreDateMax initWithTimeIntervalSince1970:0];
        coreDateMax = [NSDate dateWithTimeIntervalSince1970:0];
          NSLog(@"coreDateMax %@ ",coreDateMax);
       // [coreDateMax dateWithTimeIntervalSince1970:0];
    }
        
        
        
    
    NSLog(@"coreDateMax %@ ",coreDateMax);
    
    NSPredicate *afterDateCoreDateMax = [NSPredicate predicateWithBlock:
                            ^BOOL(id evaluatedObject, NSDictionary *bindings) {
                                NSComparisonResult result = [coreDateMax compare:[evaluatedObject updatedAt]];
                                if (result == NSOrderedAscending) {
                                    return YES;
                                } else {
                                    return NO;
                                }
                            }];
    NSArray *diffRecordsFromParse = [recParse filteredArrayUsingPredicate:afterDateCoreDateMax];
    
    
    NSLog(@"%@", diffRecordsFromParse);

    
    return diffRecordsFromParse;
}


-(NSMutableDictionary *)convertPFObjectToNSMutableDictionary:(PFObject *) recordFromParse {
    NSArray * allKeys = [recordFromParse allKeys];
    NSMutableDictionary * result = [[NSMutableDictionary alloc] init];
    
    for (NSString * key in allKeys) {
        [result setObject:[recordFromParse objectForKey:key] forKey:key];
    }
    
    [result setValue:[recordFromParse objectForKey:@"mobileFirst"] forKey:@"mobileNumber"];
    [result setValue:[recordFromParse objectForKey:@"mobileSecond"] forKey:@"homeNumber"];
    [result setValue:[recordFromParse createdAt] forKey:@"createAt"];
    [result setValue:[recordFromParse updatedAt] forKey:@"updateAt"];   
    
    return result;

}
@end
