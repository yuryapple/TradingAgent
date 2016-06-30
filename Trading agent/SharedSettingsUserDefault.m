//
//  SharedSettingsUserDefault.m
//  Trading agent
//
//  Created by  Yury_apple_mini on 5/19/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "SharedSettingsUserDefault.h"

@implementation SharedSettingsUserDefault

#pragma mark - Singelton section

static SharedSettingsUserDefault * sharedSingleton = nil;

+ (SharedSettingsUserDefault *) sharedSettingsUserDefault
{
    if (sharedSingleton == nil)
    {
        sharedSingleton = [[super allocWithZone:nil] init];
    }
    return sharedSingleton;
}

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedSettingsUserDefault];
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)dealloc {
    // Should never be called  (Singelton)
}

-(NSInteger) getDefaultOwnerNumber {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger  ownerNumber = [[defaults valueForKey:@"Owner" ]integerValue];
    return ownerNumber;
}


-(NSInteger) getDefaultCurrencyNumber {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger  currencyNumber = [[defaults valueForKey:@"Cur" ]integerValue];
return currencyNumber;
}



-(NSString *) getDefaultCurrencySign {
    NSString *signCurrency =@"Currency sign is not defined";
    
    NSURL * settingsURL =  [[NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"Settings" withExtension:@"bundle"]] URLForResource:@"Root" withExtension:@"plist"];
    NSDictionary * settingsDict = [NSDictionary dictionaryWithContentsOfURL:settingsURL];
    
    NSDictionary *currentSettings = [settingsDict valueForKey:@"PreferenceSpecifiers"];
    
     for (id object in currentSettings){
         
         if([object valueForKey:@"Key"] !=nil  &&  [[object valueForKey:@"Key"] isEqualToString:@"Cur"]){
             NSArray * currecy = [object valueForKey:@"Titles"];
             signCurrency = [currecy objectAtIndex:[self getDefaultCurrencyNumber]];
             return signCurrency;
        }
    }
    return signCurrency;
}

-(NSString *) getDefaultNameDeliveryPerson {
    NSString *nameDeliveryPerson =@"Name of Delivery Person is not defined";
    
    NSURL * settingsURL =  [[NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"Settings" withExtension:@"bundle"]] URLForResource:@"Root" withExtension:@"plist"];
    NSDictionary * settingsDict = [NSDictionary dictionaryWithContentsOfURL:settingsURL];
    
    NSDictionary *currentSettings = [settingsDict valueForKey:@"PreferenceSpecifiers"];
    
    for (id object in currentSettings){
         if([object valueForKey:@"Key"] !=nil  &&  [[object valueForKey:@"Key"] isEqualToString:@"Owner"]){
            NSArray * currecy = [object valueForKey:@"Titles"];
            nameDeliveryPerson = [currecy objectAtIndex:[self getDefaultOwnerNumber]-1];
            return nameDeliveryPerson;
        }
    }
    return nameDeliveryPerson;
}


@end
