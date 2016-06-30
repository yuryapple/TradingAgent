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
        _settingsUserDefault =[SharedSettingsUserDefault sharedSettingsUserDefault] ;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    NSString  *numberOrderStart = [NSString stringWithFormat:@"%ld%03ld01", (long)[_settingsUserDefault getDefaultOwnerNumber], (long)dc];
    NSString  *numberOrderEnd   = [NSString stringWithFormat:@"%ld%03ld99", (long)[_settingsUserDefault getDefaultOwnerNumber], (long)dc];
    
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numberOrder >= %d AND numberOrder <= %d", [numberOrderStart integerValue], [numberOrderEnd integerValue] ];
    PFQuery *query = [PFQuery queryWithClassName:@"Order" predicate:predicate];
    
    
    NSError *error = nil;
    
    // How many order exist in this day?
    NSArray *ordersInDay =  [query findObjects:&error];
    
    NSInteger nextOrderNumberInt = 0;
    
    if (!error){
        
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

@end
