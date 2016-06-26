//
//  SharedManagedObjectContext.h
//  Delivery Person
//
//  Created by  Yury_apple_mini on 3/28/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SharedManagedObjectContext : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedManager;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
