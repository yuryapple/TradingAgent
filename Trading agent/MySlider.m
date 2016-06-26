//
//  MySlider.m
//  AddressBook
//
//  Created by  Yury_apple_mini on 4/1/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "MySlider.h"

@implementation MySlider

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.nextResponder.nextResponder touchesEnded:touches withEvent:event];
}



@end
