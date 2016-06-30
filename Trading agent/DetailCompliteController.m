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
    
 //   self.sections = [NSMutableDictionary dictionary];
 //   self.sectionFood = [NSMutableDictionary dictionary];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"Inside" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
  
    
    
 //   NSString *category = @"categoryName";
    
 //   NSMutableArray *objectsInSection = [NSMutableArray array];
    
    // this is the first time we see this sportType - increment the section index
//    [self.sectionFood setObject:category forKey:[NSNumber numberWithInt:0]];
    
    
//    [objectsInSection addObject:[NSNumber numberWithInt:0]];
//    [self.sections setObject:objectsInSection forKey:category];
    
    
    
//    NSLog(@"oigoerghdfughfduhg");
    
    
//    NSLog(@"Objects %@", self.objects);
    
    
}


-(NSCache *)cache {
    if (!_cache) {
        _cache =[NSCache new];
        
        NSLog(@"Creat   ");
        
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
    
    NSLog(@"%@",predicate );
    
    PFQuery *query = [PFQuery queryWithClassName:@"Order" predicate:predicate];
    NSError *error = nil;
    NSArray *order = [query findObjects:&error];
    
    
    
     PFRelation *relation = [[order objectAtIndex:0] relationForKey:@"objectIDOrderProducts"];
    
    // generate a query based on that relation
    PFQuery *query2 = [relation query];
    
    
    
    
//    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    // if ([self.objects count] == 0) {
    //   query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    // }
    
    // [query whereKey:@"objectId" notEqualTo:@"JXCjcqAYc9"];
   // NSArray *selectedOrder = [NSArray arrayWithObjects:  [NSNumber numberWithInteger:309402] , nil];
    
//    [query whereKey:@"numberOrder" containedIn:selectedOrder];
    
//    [query orderByAscending:@"units"];
   
    
    
    NSLog(@"queryForTable       %@", query2);
    
    return query2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    
    
    
       //   NSLog(@"____________________________________  %@", self.sectionFood);
    
    
  //  UIImage *product = [self.sectionFood objectForKey:@(indexPath.row)];
    
   //  NSLog(@"_________________====___________________  %@", product);
    
    
    UIImage *product = [_cache objectForKey:[object objectForKey:@"productID"]];
    
       NSLog(@"_________________====___________________  %@", _cache);
    
    
    
    // Configure the cell
   // PFFile *thumbnail = [product objectForKey:@"foto"];
    UIImageView *thumbnailImageView = (UIImageView *)[cell viewWithTag:100];
//    thumbnailImageView.image = [UIImage imageNamed:@"photo-frame.png"];
    
    
     
//    [thumbnailImageView setImage:  [UIImage imageWithData:product scale:0.4]];
  
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
    
    
    
    NSLog(@" objectsDidLoad   ");
    
    
//    [self.sections removeAllObjects];
      self.sectionFood = [NSMutableDictionary dictionary];
    
 //   NSInteger section = 0;
    __block NSInteger rowIndex = 0;
     float sum = 0;
    
    
    int total = [self.objects count];
    
    for (PFObject *object in self.objects) {
        
        sum = sum + ([[object objectForKey:@"price"]floatValue ] * [[object objectForKey:@"units"] floatValue]);
        
        
        NSString *productId = [object objectForKey:@"productID"];
    
        NSLog(@"Sections: %@", productId);
        
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", productId];
        PFQuery *query = [PFQuery queryWithClassName:@"FoodProduct" predicate:predicate];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            
             NSLog(@"R e z u l t    %@", object);
            
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
                  //   NSLog(@"_______  %@", self.sectionFood);
                     
                 }
             });
         }];
        }];
    }
    
    self.sumLabel.text = [NSString stringWithFormat:@"%.02f", sum];
}





//  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable products, NSError * _Nullable error) {
            
        //    NSLog(@"Array %@", products);
            /*
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"dispatch product  %@", products);
                NSLog(@"dispatch  %d", rowIndex);
                
                
                 [self.sectionFood setObject:[products objectAtIndex:0] forKey:[NSNumber numberWithInt:rowIndex++]];
                NSLog(@"dispatch  %@", self.sectionFood);
            });
      */
        //    self.sectionFood = [[NSArray alloc] initWithObjects:[products initWithObjects:0], nil];
           // [self.sectionFood setObject:[products objectAtIndex:0] forKey:[NSNumber numberWithInt:rowIndex++]];
         //   NSLog(@"error: %@", [error localizedDescription]);
    
        
        
       // [query getFirstObjectInBackgroundWithBlock:^(PFObject *product, NSError *error) {
       //     [self.sectionFood setObject:product forKey:[NSNumber numberWithInt:rowIndex++]];
       //      NSLog(@"error: %@", [error localizedDescription]);
       // }];
         
       
        
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectID == %@", productId];
        
        
        
        
      //  PFQuery *query = [PFQuery queryWithClassName:@"FoodProduct" predicate:predicate];
      //  NSError *error = nil;
        
        
        
     
        
        
      //  [self.sectionFood setObject:product forKey:[NSNumber numberWithInt:rowIndex++]];
        
        
        
        
//        NSMutableArray *objectsInSection = [self.sections objectForKey:category];
//        if (!objectsInSection) {
//            objectsInSection = [NSMutableArray array];
            
            // this is the first time we see this sportType - increment the section index
        
//        }
        
//        [objectsInSection addObject:[NSNumber numberWithInt:rowIndex++]];
//        [self.sections setObject:objectsInSection forKey:category];
 
    
    //NSLog(@"___:::____  %@", [self.objects objectAtIndex:0]);
    
    // NSLog(@"Sections: %@", self.sections);
 //    NSLog(@"Sections: %@", self.sectionFood);
    
 //   [self.tableView reloadData];
    
 //   NSLog(@"error: %@", [error localizedDescription]);
    



/*

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
  //  NSString *categoryFoodName = [self headerForCategory:indexPath.section];
  //  NSArray *rowIndecesInSection = [self.sections objectForKey:categoryFoodName];
  //  NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
    
    
  //  if ([self.objects count]){
  //      NSLog(@"Objects %@", self.objects);
  //      return [self.objects objectAtIndex:[rowIndex intValue]];
  //  }
  //  return self.sectionFood ;
    
    return [self.objects objectAtIndex:indexPath.row];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   // NSLog(@"Number section : %d", self.sections.allKeys.count);
   // return self.sectionFood.allKeys.count;
    return 1;
    
}

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  //  NSString *categoryFoodName = [self headerForCategory:section];
  //  NSArray *rowIndecesInSection = [self.sections objectForKey:categoryFoodName];
    
  //  NSLog(@"umber Of rows In  section : %d", rowIndecesInSection.count);
    
  //  return rowIndecesInSection.count;
    return [self.objects count];
}


/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *categoryFoodName = [self headerForCategory:section];
    
    return categoryFoodName;
}

- (NSString *)headerForCategory:(NSInteger)section {
    NSLog(@"Header section : %@", [self.sectionFood objectForKey:[NSNumber numberWithInt:section]]);
    
    return [self.sectionFood objectForKey:[NSNumber numberWithInt:section]];
    
    
}

/*
 
 for (PFObject *object in self.objects) {
 NSString *sportType = [object objectForKey:@"sportType"];
 NSMutableArray *objectsInSection = [self.sections objectForKey:sportType];
 if (!objectsInSection) {
 objectsInSection = [NSMutableArray array];
 
 // this is the first time we see this sportType - increment the section index
 [self.sectionToSportTypeMap setObject:sportType forKey:[NSNumber numberWithInt:section++]];
 }
 
 [objectsInSection addObject:[NSNumber numberWithInt:rowIndex++]];
 [self.sections setObject:objectsInSection forKey:sportType];
 }
 
 */




/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



@end


