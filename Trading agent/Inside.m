//
//  Inside.m
//  Trading agent
//
//  Created by  Yury_apple_mini on 4/6/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "Inside.h"

@interface Inside ()
@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionFood;

@end

@implementation Inside

- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"FoodProduct";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"name";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
        self.sections = [NSMutableDictionary dictionary];
        self.sectionFood = [NSMutableDictionary dictionary];
        
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // The key of the PFObject to display in the label of the default cell style
    self.textKey = @"name";
    
    // Whether the built-in pull-to-refresh is enabled
    self.pullToRefreshEnabled = YES;
    
    // Whether the built-in pagination is enabled
    self.paginationEnabled = NO;
    
    self.sections = [NSMutableDictionary dictionary];
    self.sectionFood = [NSMutableDictionary dictionary];
    
    
    
    self.sections = [NSMutableDictionary dictionary];
    self.sectionFood = [NSMutableDictionary dictionary];
    
    NSString *category = @"categoryName";
    
    NSMutableArray *objectsInSection = [NSMutableArray array];
    
    // this is the first time we see this sportType - increment the section index
    [self.sectionFood setObject:category forKey:[NSNumber numberWithInt:0]];
    
    
    [objectsInSection addObject:[NSNumber numberWithInt:0]];
    [self.sections setObject:objectsInSection forKey:category];
    
    NSLog(@"oigoerghdfughfduhg");
    
    
    NSLog(@"Objects %@", self.objects);
    
    
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
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    // if ([self.objects count] == 0) {
    //   query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    // }
    
    // [query whereKey:@"objectId" notEqualTo:@"JXCjcqAYc9"];
    NSArray *selectedProduct = [NSArray arrayWithObjects: @"JXCjcqAYc9", nil];
    
    [query whereKey:@"objectId" notContainedIn:selectedProduct];
    
    [query orderByAscending:@"category"];
    [query addAscendingOrder:@"product"];
    
    
    NSLog(@"queryForTable");
    
    return query;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FoodCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FoodCell"];
    }
    
    // PFObject *object = [self objectAtIndexPath:indexPath];
    
    // Configure the cell
    PFFile *thumbnail = [object objectForKey:@"foto"];
    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:100];
    thumbnailImageView.image = [UIImage imageNamed:@"photo-frame.png"];
    thumbnailImageView.file = thumbnail;
    [thumbnailImageView loadInBackground];
    
    UILabel *nameLabel = (UILabel*) [cell viewWithTag:101];
    nameLabel.text = [object objectForKey:@"product"];
    
    UILabel *prepTimeLabel = (UILabel*) [cell viewWithTag:102];
    prepTimeLabel.text = [[object objectForKey:@"price"]stringValue];
    
    return cell;
}



- (void) objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    
    
    NSLog(@" objectsDidLoad   ");
    
    
    [self.sections removeAllObjects];
    [self.sectionFood removeAllObjects];
    
    NSInteger section = 0;
    NSInteger rowIndex = 0;
    
     NSLog(@"___________________________  %@", self.objects);
    
    
    for (PFObject *object in self.objects) {
        
   
        
        NSString *category = [object objectForKey:@"categoryName"];
        
        NSMutableArray *objectsInSection = [self.sections objectForKey:category];
        if (!objectsInSection) {
            objectsInSection = [NSMutableArray array];
            
            // this is the first time we see this sportType - increment the section index
            [self.sectionFood setObject:category forKey:[NSNumber numberWithInt:section++]];
        }
        
        [objectsInSection addObject:[NSNumber numberWithInt:rowIndex++]];
        [self.sections setObject:objectsInSection forKey:category];
    }
    
    NSLog(@"___:::____  %@", [self.objects objectAtIndex:0]);
    
    NSLog(@"Sections: %@", self.sections);
    NSLog(@"Sections: %@", self.sectionFood);
    
    [self.tableView reloadData];
    
    NSLog(@"error: %@", [error localizedDescription]);
    
}




- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSString *categoryFoodName = [self headerForCategory:indexPath.section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:categoryFoodName];
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
    
    
    if ([self.objects count]){
        NSLog(@"Objects %@", self.objects);
        return [self.objects objectAtIndex:[rowIndex intValue]];
    }
    return self.sectionFood ;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"Number section----- : %d", self.sections.allKeys.count);
    // return self.sectionFood.allKeys.count;
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *categoryFoodName = [self headerForCategory:section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:categoryFoodName];
    
    NSLog(@"umber Of rows In  section : %d", rowIndecesInSection.count);
    
    return rowIndecesInSection.count;
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *categoryFoodName = [self headerForCategory:section];
    
    return categoryFoodName;
}

- (NSString *)headerForCategory:(NSInteger)section {
    NSLog(@"Header section : %@", [self.sectionFood objectForKey:[NSNumber numberWithInt:section]]);
    
    return [self.sectionFood objectForKey:[NSNumber numberWithInt:section]];
    
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
