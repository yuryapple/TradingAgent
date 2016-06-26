//
//  ConvertProducts.h
//  Trading agent
//
//  Created by  Yury_apple_mini on 3/30/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConvertProductsDelegate.h"
#import "SharedManagedObjectContext.h"
#import <Parse/Parse.h>


@interface ConvertProducts : NSObject

@property (weak) id<ConvertProductsDelegate> controllerDelegate;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(void)convertParseToCoreData: (NSString *) orderNumber;
-(void)convertCoreDataToParse: (NSString *) orderNumber forClientID:(NSString *) clientID withProducts:(NSArray *) products forNewOrder: (BOOL) isNew;

@end
