//
//  FoodList.m
//  FoofList
//
//  Created by  Yury_apple_mini on 3/21/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "FoodListController.h"
#import "ProductItemController.h"

@interface FoodListController ()
@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionFood;
@end

@implementation FoodListController

@synthesize    productsExistInOrder = _productsExistInOrder;

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

        _settingsUserDefault =[SharedSettingsUserDefault sharedSettingsUserDefault] ;
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _managedObjectContext =[[SharedManagedObjectContext sharedManager] managedObjectContext] ;

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
    
    [query whereKey:@"objectId" notContainedIn:_productsExistInOrder];
    
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
    

    UILabel *productPrice = (UILabel*) [cell viewWithTag:102];
    
    if ([_settingsUserDefault getDefaultCurrencyNumber] == 0 ){
        productPrice.text =  [NSString stringWithFormat:@"%@ %@", [[object valueForKey:@"price"] description] , [_settingsUserDefault getDefaultCurrencySign]];
    } else {
        productPrice.text =  [NSString stringWithFormat:@"%@ %@", [_settingsUserDefault getDefaultCurrencySign],  [[object valueForKey:@"price"] description]];
    }
    
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
     return self.sectionFood.allKeys.count;
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



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"newSelectProduct"]) {
    
        NSIndexPath *selectCellPath = [self.tableView indexPathForCell:sender];
 
    
        NSString *categoryFoodName = [self headerForCategory:selectCellPath.section];
        NSArray *rowIndecesInSection = [self.sections objectForKey:categoryFoodName];
        NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:selectCellPath.row];
        
        PFObject *selectObject = [self.objects objectAtIndex: [rowIndex intValue]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numberOrder = %d",[_numberOrder intValue]];
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    
        request.predicate = predicate;
    
    
        NSManagedObject *currentOrder = [[[self managedObjectContext] executeFetchRequest:request error:nil] objectAtIndex:0];
    
        NSMutableSet *orderProduct = [currentOrder mutableSetValueForKey:@"orderProducts"];
    
    
        NSEntityDescription *productCoreDate = [NSEntityDescription entityForName:@"OrderProduct" inManagedObjectContext:_managedObjectContext];
        NSManagedObject *newProduct = [[NSManagedObject alloc] initWithEntity:productCoreDate insertIntoManagedObjectContext:_managedObjectContext];
        [newProduct setValue:[selectObject valueForKey:@"objectId"] forKey:@"objectIDProductParse"];
        [newProduct setValue:[selectObject valueForKey:@"weight"] forKey:@"weight"];
        [newProduct setValue:[selectObject valueForKey:@"price"] forKey:@"price"];
        [newProduct setValue:@(1) forKey:@"units"];
    
        [orderProduct  addObject:newProduct ];
    
        [[SharedManagedObjectContext sharedManager] saveContext];
    
        ProductItemController *controller = (ProductItemController *)[segue destinationViewController] ;
        [controller setSourceViewControllerName : @"newSelectProduct"];
        [controller setNumberOrder :_numberOrder];
        [controller setSelectProduct : newProduct];
    }

}

- (IBAction)addNewProductTo:(UIStoryboardSegue *)unwindSegue
{
    if ([[unwindSegue identifier] isEqualToString:@"unwindAddNewProducts"]) {
        ProductItemController* controller = unwindSegue.sourceViewController;
        [_productsExistInOrder addObject:controller.productId];
        [self loadObjects];
    }
}


@end

