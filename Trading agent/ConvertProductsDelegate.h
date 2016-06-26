//
//  ConvertProductsDelegate.h
//  Trading agent
//
//  Created by  Yury_apple_mini on 3/30/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ConvertProductsDelegate <NSObject>

-(void)convertDidCompliteParseToCoreData;
-(void)convertDidCompliteCoreDataToParse;

@end
