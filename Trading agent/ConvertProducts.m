//
//  ConvertProducts.m
//  Trading agent
//

//  Created by  Yury_apple_mini on 3/30/16.//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "ConvertProducts.h"
#import "SharedManagedObjectContext.h"
#import <Parse/Parse.h>

@implementation ConvertProducts

- (id)init {
    self = [super init];
    if (self) {
          _managedObjectContext =[[SharedManagedObjectContext sharedManager] managedObjectContext] ;
    }
    return self;
}

-(void)convertParseToCoreData:(NSString *) orderNumber{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numberOrder == %d", [orderNumber integerValue]];
    PFQuery *query = [PFQuery queryWithClassName:@"Order" predicate:predicate];

   [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable order, NSError * _Nullable error) {
       if (!error){
           NSEntityDescription *orderCoreDate = [NSEntityDescription entityForName:@"Order" inManagedObjectContext:_managedObjectContext];
           NSManagedObject *newOrder = [[NSManagedObject alloc] initWithEntity:orderCoreDate insertIntoManagedObjectContext:_managedObjectContext];
           
           [newOrder setValue:[order valueForKey:@"clientID"] forKey:@"clientID"];
           [newOrder setValue:[order valueForKey:@"numberOrder"] forKey:@"numberOrder"];
           
           NSMutableSet *orderProduct = [newOrder mutableSetValueForKey:@"orderProducts"];
           
           [[SharedManagedObjectContext sharedManager] saveContext];
           
           PFRelation *relation = [order  relationForKey:@"objectIDOrderProducts"];
           
           // generate a query based on that relation
           PFQuery *queryProd = [relation query];
           
           // now execute the query
           [queryProd findObjectsInBackgroundWithBlock:^(NSArray * _Nullable products, NSError * _Nullable error) {
               if (!error){
                   
                   if (products.count) {
                       for (PFObject *object in products) {
                           NSEntityDescription *productCoreDate = [NSEntityDescription entityForName:@"OrderProduct" inManagedObjectContext:_managedObjectContext];
                           NSManagedObject *newProduct = [[NSManagedObject alloc] initWithEntity:productCoreDate insertIntoManagedObjectContext:_managedObjectContext];
                           [newProduct setValue:[object valueForKey:@"productID"] forKey:@"objectIDProductParse"];
                           [newProduct setValue:[object valueForKey:@"weight"] forKey:@"weight"];
                           [newProduct setValue:[object valueForKey:@"price"] forKey:@"price"];
                           [newProduct setValue:[object valueForKey:@"units"] forKey:@"units"];
                           
                           [orderProduct  addObject:newProduct ];
                           
                           [[SharedManagedObjectContext sharedManager] saveContext];
                       }
                   }
                   
                   [[SharedManagedObjectContext sharedManager] saveContext];
                   [self.controllerDelegate  convertDidCompliteParseToCoreData];
                   
               }else {
                   NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
               }
           }];
       }else {
           NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
       }
   }];
}

-(void)convertCoreDataToParse:(NSString *) orderNumber forClientID:(NSString *) clientID withProducts:(NSArray *) products forNewOrder: (BOOL) isNew {
    NSLog(@"Convert to Parse %@", orderNumber);
    
    PFObject *oldOrNewOrder;
    
    if (isNew) {
        oldOrNewOrder = [PFObject objectWithClassName:@"Order"];
        oldOrNewOrder[@"numberOrder"] = @([orderNumber integerValue]);
        oldOrNewOrder[@"clientID"] = clientID;
        oldOrNewOrder[@"dateOrder"] = [NSDate date];
        
        [self addProducts:products toOrder:oldOrNewOrder ];

        
    }else{
        // order was saved to Parse then it was editing
        PFQuery *query = [PFQuery queryWithClassName:@"Order"];
        [query whereKey:@"numberOrder" equalTo:@([orderNumber integerValue])];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable oldOrNewOrder, NSError * _Nullable error) {
            
            
            oldOrNewOrder[@"dateOrder"] = [NSDate date];
            
            PFRelation *relation = [oldOrNewOrder relationForKey:@"objectIDOrderProducts"];
            
            PFQuery *query2 = [relation query];
            
            [query2 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable oldProducts, NSError * _Nullable error) {
               
                [PFObject deleteAllInBackground: oldProducts block:^(BOOL succeeded, NSError * _Nullable error) {
                    
                    if (succeeded){
                        [self addProducts:products toOrder:oldOrNewOrder ];
                    }
                    
                }];
            }];
        }];
    }
}


-(void)addProducts:(NSArray *) products  toOrder: (PFObject *) oldOrNewOrder {

    NSMutableArray *newItemProductsArray = [NSMutableArray array];
    PFRelation *relation = [oldOrNewOrder relationForKey:@"objectIDOrderProducts"];
    
    for (NSManagedObject *product in products){
        PFObject *newItemProduct = [PFObject objectWithClassName:@"OrderProduct"];
        newItemProduct[@"productID"] = [product valueForKey:@"objectIDProductParse"];
        newItemProduct[@"price"] = [product valueForKey:@"price"];
        newItemProduct[@"weight"] = [product valueForKey:@"weight"];
        newItemProduct[@"units"] = [product valueForKey:@"units"];
        
        [newItemProductsArray addObject:newItemProduct];
        [relation addObject:newItemProduct];
    }
    
    NSLog(@"newItemProductsArray %@", newItemProductsArray);
    
    [PFObject saveAllInBackground:newItemProductsArray block:^(BOOL succeeded, NSError * _Nullable error) {
        
        NSLog(@"Save all products in Background  %d", succeeded );
        
        if (succeeded) {
            [oldOrNewOrder saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded){
                    [self.controllerDelegate  convertDidCompliteCoreDataToParse];
                } else {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
            }];
        } else {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }];

}

@end
