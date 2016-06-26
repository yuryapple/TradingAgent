//
//  DetailAddressBookController.m
//  Delivery Person
//
//  Created by  Yury_apple_mini on 3/16/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "DetailAddressBookController.h"
#import "OrderClienController.h"
#import <Parse/Parse.h>

@interface DetailAddressBookController ()

@property (nonatomic, assign) NSInteger nextOrderNumberInt;
-(void)userInteractionButton:(int)tag enabling:(BOOL)enable ;

@end

@implementation DetailAddressBookController


- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        _managedObjectContext =[[SharedManagedObjectContext sharedManager] managedObjectContext] ;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
  
    
    NSLog(@"_dictContactDetails %@", _dictContactDetails );
    
    
    NSString *firstName = [_dictContactDetails objectForKey:@"firstName"];
    NSString *lastName = [_dictContactDetails objectForKey:@"lastName"];
    NSString *phoneNumberMobile = [_dictContactDetails objectForKey:@"mobileNumber"];
    NSString *phoneNumberHome = [_dictContactDetails objectForKey:@"homeNumber"];
    
    if ([phoneNumberMobile length] == 0)
        [self userInteractionButton:1 enabling:NO];
    
    
    if ([phoneNumberHome length] == 0)
        [self userInteractionButton:2 enabling:NO];
    
    
    
    _fieldFirstName.text = firstName;
    _fieldLastName.text = lastName;
    _fieldMobilePhoneNumber.text= phoneNumberMobile;
    _fieldHomePhoneNumber.text = phoneNumberHome;
    
    
    // Get user preference
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger  cur = [[defaults valueForKey:@"Cur" ]integerValue];
    NSInteger  owne = [[defaults valueForKey:@"Owner" ]integerValue];

 
    
    NSLog(@"Currency %ld", (long)cur );
    NSLog(@"Currency %ld", (long)owne );
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)userInteractionButton:(int)tag enabling:(BOOL)isEnable
{
   UIButton *buttonCall = (UIButton *)[self.view viewWithTag:tag];
    buttonCall.enabled = isEnable;
   buttonCall.userInteractionEnabled = isEnable;
    
}


- (IBAction)callMobilePhoneNumber:(id)sender {
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _fieldMobilePhoneNumber.text]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
    
}

- (IBAction)callHomePhoneNumber:(id)sender {
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _fieldHomePhoneNumber.text]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
    
}

- (IBAction)newOrder:(id)sender {
    [self nextOrderNumber];
    
    if (_nextOrderNumberInt){
       [self saveNewOrderToParse];
       [self performSegueWithIdentifier:@"showOrder" sender:self];
    }
}



// Range number of orders
-(void) nextOrderNumber{

    //Genetate number order
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];
    NSInteger dc = [currentCalendar  ordinalityOfUnit:NSDayCalendarUnit
                                               inUnit:NSYearCalendarUnit
                                              forDate:today];
    
    
    //  example of order number   (3)(089)(04)
    // 1 - Tom
    // 2 - Bob
    // 3 - Tim
    
    // day of year -  89   29/03/2016
    
    // orders in day  4   (all 99 orders in day)
    
    
    //range of order number avaliable in this day
    NSString  *numberOrderStart = [NSString stringWithFormat:@"3%03ld01",(long)dc];
    NSString  *numberOrderEnd = [NSString stringWithFormat:@"3%03ld99",(long)dc];
    
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numberOrder >= %d AND numberOrder <= %d", [numberOrderStart integerValue], [numberOrderEnd integerValue] ];
    PFQuery *query = [PFQuery queryWithClassName:@"Order" predicate:predicate];
    
    
    NSError *error = nil;
    // How many order exist in this day?
    NSArray *ordersInDay =  [query findObjects:&error];
    
    NSInteger nextOrderNumberInt = 0;
    
    if (!error){

         // The find succeeded.
         NSLog(@"Successfully retrieved %lu scores.", (unsigned long)ordersInDay.count);
         
        
         if  (ordersInDay.count) {
             int maximumValue = [[ordersInDay valueForKeyPath: @"@max.numberOrder"]intValue];
             
             if (maximumValue < numberOrderEnd.intValue){
                 nextOrderNumberInt = ++maximumValue ;
             }
         } else {
             nextOrderNumberInt =  numberOrderStart.intValue;
         }
        

 
    } else {
    // Log details of the failure
    NSLog(@"Error: %@ %@", error, [error userInfo]);
    }
    
    self.nextOrderNumberInt = nextOrderNumberInt;
}
    

-(void) saveNewOrderToParse{
         NSEntityDescription *orderCoreDate = [NSEntityDescription entityForName:@"Order" inManagedObjectContext:_managedObjectContext];
         NSManagedObject *newOrder = [[NSManagedObject alloc] initWithEntity:orderCoreDate insertIntoManagedObjectContext:_managedObjectContext];
         
         
         [newOrder setValue:[_dictContactDetails objectForKey:@"clientID"] forKey:@"clientID"];
         [newOrder setValue:  @(_nextOrderNumberInt) forKey:@"numberOrder"];
         
         
         [[SharedManagedObjectContext sharedManager] saveContext];
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showOrder"]) {
        OrderClienController *controller = (OrderClienController *)[[segue destinationViewController] topViewController];
        [controller setNumberOrder :[NSString stringWithFormat:@"%ld", (long)_nextOrderNumberInt]];
    }
}


    /*
        //Genetate number order
        NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        NSDate *today = [NSDate date];
        NSInteger dc = [currentCalendar  ordinalityOfUnit:NSDayCalendarUnit
                                                   inUnit:NSYearCalendarUnit
                                                  forDate:today];
        
        
        //  example of order number   (3)(089)(04)
        // 1 - Tom
        // 2 - Bob
        // 3 - Tim
        
        // day of year -  89   29/03/2016
        
        // orders in day  4   (all 99 orders in day)
    
    
        //range of order number avaliable in this day
        NSString  *numberOrderStart = [NSString stringWithFormat:@"3%03ld01",(long)dc];
        NSString  *numberOrderEnd = [NSString stringWithFormat:@"3%03ld99",(long)dc];
    
    
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numberOrder >= %d AND numberOrder <= %d", [numberOrderStart integerValue], [numberOrderEnd integerValue] ];
        PFQuery *query = [PFQuery queryWithClassName:@"Order" predicate:predicate];
    
    
        NSError *error = nil;
    
        // How many order exist in this day?
        NSArray *ordersInDay =  [query findObjects:&error];
    
    
    
    
    
    
        if (!error) {
           NSInteger nextOrderNumberInt = 0;
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu scores.", (unsigned long)ordersInDay.count);
            
            
                    if  (ordersInDay.count) {
                       int maximumValue = [[ordersInDay valueForKeyPath: @"@max.numberOrder"]intValue];
                        
                        if (maximumValue < numberOrderEnd.intValue){
                            nextOrderNumberInt = ++maximumValue ;
                        }
                    } else {
                        nextOrderNumberInt =  numberOrderStart.intValue;
                    }
            
            
            //
            
            NSEntityDescription *orderCoreDate = [NSEntityDescription entityForName:@"Order" inManagedObjectContext:_managedObjectContext];
            NSManagedObject *newOrder = [[NSManagedObject alloc] initWithEntity:orderCoreDate insertIntoManagedObjectContext:_managedObjectContext];
            
           
            [newOrder setValue:[_dictContactDetails objectForKey:@"clientID"] forKey:@"clientID"];
            [newOrder setValue:  @(nextOrderNumberInt) forKey:@"numberOrder"];

            
             [[SharedManagedObjectContext sharedManager] saveContext];
            
            /*
            
            PFObject *nextOrder = [PFObject objectWithClassName:@"Order"];
            nextOrder[@"numberOrder"] = @(nextOrderNumberInt);
            nextOrder[@"clientID"] = [_dictContactDetails objectForKey:@"clientID"];
            
            
            PFObject *onion = [PFObject objectWithClassName:@"OrderProduct"];
            onion[@"productID"] = @"gpDxYuKCw9";
            onion[@"price"] =@10;
            onion[@"weight"] = @300;
            onion[@"units"] = @5;
            [onion save:&error];
            
            
            PFObject *midii = [PFObject objectWithClassName:@"OrderProduct"];
            midii[@"productID"] = @"siBqY89Ywu";
            midii[@"price"] =@100;
            midii[@"weight"] = @500;
            midii[@"units"] = @1;
            [midii save:&error];
        
            
            PFRelation *relation = [nextOrder relationForKey:@"objectIDOrderProducts"];
            [relation addObject:onion];
            [relation addObject:midii];
     
        
            [nextOrder save:&error];
            
            */
@end
