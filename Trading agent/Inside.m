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
    
    [self.sectionFood setObject:category forKey:[NSNumber numberWithInt:0]];
    
    
    [objectsInSection addObject:[NSNumber numberWithInt:0]];
    [self.sections setObject:objectsInSection forKey:category];
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
    
    NSArray *selectedProduct = [NSArray arrayWithObjects: @"JXCjcqAYc9", nil];
    
    [query whereKey:@"objectId" notContainedIn:selectedProduct];
    
    [query orderByAscending:@"category"];
    [query addAscendingOrder:@"product"];
    
    return query;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FoodCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FoodCell"];
    }
    
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
    
    [self.sections removeAllObjects];
    [self.sectionFood removeAllObjects];
    
    NSInteger section = 0;
    NSInteger rowIndex = 0;
    
    for (PFObject *object in self.objects) {
        
        NSString *category = [object objectForKey:@"categoryName"];
        
        NSMutableArray *objectsInSection = [self.sections objectForKey:category];
        if (!objectsInSection) {
            objectsInSection = [NSMutableArray array];
            
           
            [self.sectionFood setObject:category forKey:[NSNumber numberWithInt:section++]];
        }
        
        [objectsInSection addObject:[NSNumber numberWithInt:rowIndex++]];
        [self.sections setObject:objectsInSection forKey:category];
    }
    
    [self.tableView reloadData];
}


- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSString *categoryFoodName = [self headerForCategory:indexPath.section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:categoryFoodName];
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
    
    if ([self.objects count]){
        return [self.objects objectAtIndex:[rowIndex intValue]];
    }
    return (PFObject *)self.sectionFood ;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *categoryFoodName = [self headerForCategory:section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:categoryFoodName];
    
    return rowIndecesInSection.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *categoryFoodName = [self headerForCategory:section];
    
    return categoryFoodName;
}

- (NSString *)headerForCategory:(NSInteger)section {
    return [self.sectionFood objectForKey:[NSNumber numberWithInt:section]];
}




@end
