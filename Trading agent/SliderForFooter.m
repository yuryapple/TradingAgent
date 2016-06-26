//
//  MySlider.m
//  SliderTable
//
//  Created by  Yury_apple_mini on 4/2/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "SliderForFooter.h"

@interface SliderForFooter ()

@end

@implementation SliderForFooter

-(id)init{
 if(self = [super init]) {
   self.view.frame =  CGRectMake(0, 0, 150, 35);
 }
    return self;
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.delegate.tableView reloadData];
    
    NSRange range = NSMakeRange(self.section, 1);
    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.delegate.tableView beginUpdates];
    [self.delegate.tableView deleteSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    [self.delegate.tableView insertSections:sectionToReload withRowAnimation:UITableViewRowAnimationMiddle];
    [self.delegate.tableView endUpdates];
    
 
}

     

- (void)viewDidLoad {
    [super viewDidLoad];
    _days =1;
   // _label.text = [NSString stringWithFormat:@"%d %@",_days , NSLocalizedString(@"Days", nil)];
    
   _label.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d Day(s)", nill), _days];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)ShowValue:(id)sender {
    
     _days =(int)[(UISlider *)sender value];
  //  _label.text = [NSString stringWithFormat:@"%d %@",_days , NSLocalizedString(@"Days", nil)];
    
      _label.text = [NSString localizedStringWithFormat:NSLocalizedString(@"%d Day(s)", nill), _days];
    
}
@end
