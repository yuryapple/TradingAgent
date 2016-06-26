//
//  ProductItemController.h
//  Trading agent
//
//  Created by  Yury_apple_mini on 4/14/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedManagedObjectContext.h"
#import "SharedSettingsUserDefault.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


@interface ProductItemController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong ) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) SharedSettingsUserDefault *settingsUserDefault;

@property (weak, nonatomic)  NSManagedObject  *selectProduct;
@property (nonatomic, weak)  NSString *numberOrder;
@property (nonatomic, weak)  NSString *productId;
@property (nonatomic, weak)  NSString *sourceViewControllerName;

@property (weak, nonatomic) IBOutlet UITextField *textUnits;
@property (weak, nonatomic) IBOutlet UILabel *orderLabel;
@property (weak, nonatomic) IBOutlet UILabel *sumLabel;
@property (weak, nonatomic) IBOutlet UILabel *kgLabel;
@property (weak, nonatomic) IBOutlet PFImageView *foto;

@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

- (IBAction)AddToOrderOrSave:(id)sender;

- (IBAction)cancel:(id)sender;

@end
