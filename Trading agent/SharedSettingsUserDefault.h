//
//  SharedSettingsUserDefault.h
//  Trading agent
//
//  Created by  Yury_apple_mini on 5/19/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharedSettingsUserDefault : NSObject
+ (id)sharedSettingsUserDefault;

/*!
 @brief It get index of owner Address Book  (name of delivery person)  from NSUserDefaults.
 See Settings.bundle for more information.
 
 @param  empty.
 
 @return Index of owner's Address Book.
 */
-(NSInteger) getDefaultOwnerNumber;


/*!
 @brief It get index of currency .
 See Settings.bundle for more information.
 
 @param  empty.
 
 @return Index of ocurrency.
 */
-(NSInteger) getDefaultCurrencyNumber;

/*!
 @brief It get sign of currency .
 See Settings.bundle for more information.
 
 @param  empty.
 
 @return Sign of ocurrency.
 */
-(NSString *) getDefaultCurrencySign;

/*!
 @brief It get name of  a currency delivery person  .
 See Settings.bundle for more information.
 
 @param  empty.
 
 @return name of  a currency delivery person.
 */
-(NSString *) getDefaultNameDeliveryPerson;

@end
