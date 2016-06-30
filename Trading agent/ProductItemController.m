//
//  ProductItemController.m
//  Trading agent
//
//  Created by  Yury_apple_mini on 4/14/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "ProductItemController.h"

@interface ProductItemController ()

@property (nonatomic) CGRect centerView;

-(void)buttonEnable;
-(void)buttonDisable;
-(void)reCalculation: (NSInteger) units;
-(void)registerForKeyboardNotifications;
-(void)keyboardWillShown:(NSNotification*)aNotification;

@end

@implementation ProductItemController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _settingsUserDefault =[SharedSettingsUserDefault sharedSettingsUserDefault];
    
    _orderLabel.text =  _numberOrder;
    
    _weightLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Weight", nil),[[_selectProduct valueForKey:@"weight"]stringValue]];
    
    
    
    if ([_settingsUserDefault getDefaultCurrencyNumber] == 0 ){
        _priceLabel.text =  [NSString stringWithFormat:@"%@ %@", [[_selectProduct valueForKey:@"price"]stringValue ] , [_settingsUserDefault getDefaultCurrencySign]];
    } else {
        _priceLabel.text =  [NSString stringWithFormat:@"%@ %@", [_settingsUserDefault getDefaultCurrencySign], [[_selectProduct valueForKey:@"price"]stringValue ]];
    }

    _textUnits.text = [[_selectProduct valueForKey:@"units"]stringValue ];
    
    
    UIButton *addOrSaveButton = (UIButton *)[self.view viewWithTag:200];
    
    if ([_sourceViewControllerName isEqualToString:@"newSelectProduct"]){
        [addOrSaveButton setTitle:NSLocalizedString(@"Add new product to order", nil) forState:normal ];
    }else{
        [addOrSaveButton setTitle:NSLocalizedString(@"Save", nil) forState:normal ];
    }
    
    _productId = [_selectProduct valueForKey:@"objectIDProductParse"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", _productId];
    
    PFQuery *query = [PFQuery queryWithClassName:@"FoodProduct" predicate:predicate];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        
        [[object objectForKey:@"foto"]getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            
            UIImage  *foto =  [UIImage imageWithData:data scale:1];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _foto.image = foto;
              
            });
        }];
    }];

    [self reCalculation:[[_selectProduct valueForKey:@"units"]integerValue]];

    _centerView = [[self view]bounds];
    [self registerForKeyboardNotifications];
    [[self textUnits]canBecomeFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSInteger newValue;
    
    if (![string  isEqual: @""]){
        newValue  = [[textField.text stringByAppendingString:string]integerValue ];
    }else {
        newValue  = [[textField.text substringToIndex:range.location]integerValue];
    }
    
    
    
    if (newValue < 201 && newValue >= 0 ) {
        [self reCalculation:newValue];
        return YES;
    } else {
    return NO;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (!textField.hasText  || [textField.text integerValue] == 0 ) {
        textField.text = [[_selectProduct valueForKey:@"units"]stringValue ];
        [self reCalculation:[[_selectProduct valueForKey:@"units"]integerValue]];
    }
}


-(void)reCalculation :(NSInteger) units {
    double price =  [[_selectProduct valueForKey:@"price"] doubleValue] ;
    NSInteger weight =  [[_selectProduct valueForKey:@"weight"] integerValue];
    
    if ([_settingsUserDefault getDefaultCurrencyNumber] == 0 ){
        _sumLabel.text =  [NSString stringWithFormat:@"%.2f %@", price * units , [_settingsUserDefault getDefaultCurrencySign]];
    } else {
       _sumLabel.text =  [NSString stringWithFormat:@"%@ %.2f", [_settingsUserDefault getDefaultCurrencySign], price * units];
    }
    
    _kgLabel.text =  [NSString stringWithFormat:@"%@ %.0d", NSLocalizedString(@"Weight", nil), weight * units];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [[self view] endEditing:YES ];
    return YES;
}




- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:YES ];
}


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGFloat heightKeyboar  = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    CGPoint center = CGPointMake(_centerView.size.width /2, _centerView.size.height/2 - heightKeyboar);
    self.view.center = center;
    [self buttonDisable];
}


- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    CGPoint center = CGPointMake(_centerView.size.width /2, _centerView.size.height/2);
    self.view.center = center;
    [self buttonEnable];
}


-(void)buttonEnable{
   UIButton *addOrSaveButton = (UIButton *)[self.view viewWithTag:200];
    addOrSaveButton.enabled = YES;
    
   UIButton *canselButton = (UIButton *)[self.view viewWithTag:201];
    canselButton.enabled = YES;
}

-(void)buttonDisable{
    UIButton *addOrSaveButton = (UIButton *)[self.view viewWithTag:200];
    addOrSaveButton.enabled = NO;
    
    UIButton *canselButton = (UIButton *)[self.view viewWithTag:201];
    canselButton.enabled = NO;
}



- (IBAction)AddToOrderOrSave:(id)sender {
    [_selectProduct setValue:@([_textUnits.text integerValue])  forKey:@"units"];
    [[SharedManagedObjectContext sharedManager] saveContext];
    
    
    if ([[(UIButton*)sender currentTitle] isEqualToString: @"Add new product to order"]){
        [self performSegueWithIdentifier:@"unwindAddNewProducts" sender:self];
    }else{
        [self performSegueWithIdentifier:@"UnwindEditProductTo" sender:self];
    }
}

- (IBAction)cancel:(id)sender {
    if ([_sourceViewControllerName isEqualToString:@"newSelectProduct"]){
        NSManagedObjectContext *context = [_selectProduct managedObjectContext];
        
        [context deleteObject:_selectProduct];
        [[SharedManagedObjectContext sharedManager] saveContext];
    }
     [self dismissViewControllerAnimated:YES completion:nil];
}
@end
