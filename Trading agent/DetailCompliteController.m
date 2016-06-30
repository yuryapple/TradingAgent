//
//  DetailCompliteController.m
//  Trading agent
//
//  Created by  Yury_apple_mini on 4/5/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "DetailCompliteController.h"



@interface DetailCompliteController ()
@property (nonatomic, readonly)  NSCache *cache;
@property (nonatomic, strong ) __block NSMutableDictionary *sectionFood;
@end

@implementation DetailCompliteController

@synthesize cache = _cache;

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Order";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"name";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
      //  self.sections = [NSMutableDictionary dictionary];
         self.sectionFood = [NSMutableDictionary dictionary];
        
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"Inside" bundle:nil] forCellReuseIdentifier:@"Cell"];
}


-(NSCache *)cache {
    if (!_cache) {
        _cache =[NSCache new];
    }
        return _cache;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}




- (PFQuery *)queryForTable
{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numberOrder == %d",[self.numberOrder intValue]];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Order" predicate:predicate];
    NSError *error = nil;
    NSArray *order = [query findObjects:&error];
    
    
    
     PFRelation *relation = [[order objectAtIndex:0] relationForKey:@"objectIDOrderProducts"];
    
    // generate a query based on that relation
    PFQuery *query2 = [relation query];
    
    return query2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UIImage *product = [_cache objectForKey:[object objectForKey:@"productID"]];
    UIImageView *thumbnailImageView = (UIImageView *)[cell viewWithTag:100];

    [thumbnailImageView setImage: product] ;
    
    UILabel *priceLabel = (UILabel*) [cell viewWithTag:101];
    priceLabel.text = [[object objectForKey:@"price"]stringValue];
   
    UILabel *unitsLabel = (UILabel*) [cell viewWithTag:102];
    unitsLabel.text = [[object objectForKey:@"units"]stringValue];
    
    UILabel *sumLabel = (UILabel*) [cell viewWithTag:103];
    sumLabel.text =  [NSString stringWithFormat:@"%.02f", [[object objectForKey:@"price"] floatValue ] * [[object objectForKey:@"units"] floatValue]];

    return cell;
}



- (void) objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];

      self.sectionFood = [NSMutableDictionary dictionary];

    __block NSInteger rowIndex = 0;
     float sum = 0;
    
    
    int total = [self.objects count];
    
    for (PFObject *object in self.objects) {
        
        sum = sum + ([[object objectForKey:@"price"]floatValue ] * [[object objectForKey:@"units"] floatValue]);
        
        
        NSString *productId = [object objectForKey:@"productID"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", productId];
        PFQuery *query = [PFQuery queryWithClassName:@"FoodProduct" predicate:predicate];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
         [[object objectForKey:@"foto"]getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
    
             UIImage  *foto =  [UIImage imageWithData:data scale:0.4];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 @synchronized(self.sectionFood) {
             
                     UIImage *existFoto = [_cache objectForKey:productId];
                     if (!existFoto)
                     {
                         [self.cache setObject: foto forKey:productId];
                     }
                     
                     [self.sectionFood setObject: foto forKey:[NSNumber numberWithInt:rowIndex++]];
                     
                      if (total == rowIndex)
                      [self.tableView reloadData];
                 }
             });
         }];
        }];
    }
    
    self.sumLabel.text = [NSString stringWithFormat:@"%.02f", sum];
}

@end


