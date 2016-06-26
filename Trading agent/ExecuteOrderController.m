//
//  ExecuteOrderController.m
//  Trading agent
//
//  Created by  Yury_apple_mini on 4/13/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "ExecuteOrderController.h"
#import "OrderClienController.h"

@interface ExecuteOrderController ()
@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionOrder;
@property (nonatomic, retain) NSMutableDictionary *sections1;

//@property (nonatomic, strong) SliderForFooter *sl;
//@property (nonatomic ,strong) NSMutableArray * sArray;
@end

@implementation ExecuteOrderController

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
        
        self.sections = [NSMutableDictionary dictionary];
        self.sectionOrder = [NSMutableDictionary dictionary];
        self.sections1 = [NSMutableDictionary dictionary];
        
        
        _managedObjectContext =[[SharedManagedObjectContext sharedManager] managedObjectContext] ;
        _settingsUserDefault =[SharedSettingsUserDefault sharedSettingsUserDefault] ;
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableWithCurrentSettings)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    
    self.navigationItem.title = [[NSString stringWithFormat:@"%@ - ", NSLocalizedString([_settingsUserDefault getDefaultNameDeliveryPerson], nil)] stringByAppendingString:NSLocalizedString(@"Delivery", nil)];
    
    NSString *clientName = @"clientName";
    NSMutableArray *objectsInSection = [NSMutableArray array];
    [self.sectionOrder setObject:clientName forKey:[NSNumber numberWithInt:0]];
    [objectsInSection addObject:[NSNumber numberWithInt:0]];
    [self.sections setObject:objectsInSection forKey:clientName];
    
    
    NSLog(@" view   Did    Load  ");
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

-(void)viewWillAppear:(BOOL)animated{
 [self loadObjects];
}


-(void)reloadTableWithCurrentSettings {
     self.navigationItem.title = [[NSString stringWithFormat:@"%@ - ", NSLocalizedString([_settingsUserDefault getDefaultNameDeliveryPerson], nil)] stringByAppendingString:NSLocalizedString(@"Delivery", nil)];
    [self loadObjects];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}






#pragma mark - PF Query Table View Controller

- (PFQuery *)queryForTable
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:   @"numberOrder > %d AND numberOrder < %d",
                                [[NSString stringWithFormat:@"%ld00000",(long)[_settingsUserDefault getDefaultOwnerNumber]] integerValue],
                                [[NSString stringWithFormat:@"%ld36700",(long)[_settingsUserDefault getDefaultOwnerNumber]] integerValue]
    ];
    
    
    
    
    NSLog(@"%@", predicate);
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName  predicate:predicate];
    [query whereKey:@"dateComplete" equalTo:[NSNull null]];
    [query orderByAscending:@"clientID"];
    [query addDescendingOrder:@"numberOrder"];
    
    
    
    //PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
     if ([self.objects count] == 0) {
       query.cachePolicy = kPFCachePolicyCacheElseNetwork;
       query.maxCacheAge = 1;
     }
 

    
  //  PFQuery *query = [PFQuery queryWithClassName:self.parseClassName  predicate:predicate];
    
    
   // [query whereKey:@"dateComplete" equalTo:[NSNull null]];
    
    
    
    
  //  [query whereKey:@"numberOrder" begi : [@([_settingsUserDefault getDefaultOwnerNumber]) stringValue]];
    
    
//    [query orderByAscending:@"clientID"];
//    [query addDescendingOrder:@"numberOrder"];
    
    return query;
}


- (void) objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    
    NSLog(@"All objects in table   %@", self.objects);
    
    
    [self.sections removeAllObjects];
    [self.sectionOrder removeAllObjects];
    [self.sections1 removeAllObjects];
    
    
    NSInteger section = 0;
    NSInteger rowIndex = 0;
    
    
    
    
    for (PFObject *object in self.objects) {
        
        NSString *clientID = [object objectForKey:@"clientID"];
        NSString *numberOrder = [object objectForKey:@"numberOrder"] ;
        
        NSMutableArray *objectsInSection = [self.sections objectForKey:clientID];
        NSMutableArray *objectsOrderInSection = [self.sections1 objectForKey:clientID];
        
        if (!objectsInSection) {
            
            objectsInSection = [NSMutableArray array];
            objectsOrderInSection = [NSMutableArray array];
            
            [self.sectionOrder setObject:clientID forKey:[NSNumber numberWithInt:section++]];
            // [self.sectionOrderNumber setObject:numberOrder forKey:[NSNumber numberWithInt:section]];
        }
        
        [objectsInSection addObject:[NSNumber numberWithInt:rowIndex++]];
        [objectsOrderInSection addObject:numberOrder];
        
        [self.sections setObject:objectsInSection forKey:clientID];
        [self.sections1 setObject:objectsOrderInSection forKey:clientID];
        
    }
    
    
    NSLog(@"All objects in   s e c t i o n    %@", self.sections);
    NSLog(@"All objects in    s e c t i o n 1     %@", self.sections1);
    
    
    
    [self.tableView reloadData];
    
    NSLog(@"error: %@", [error localizedDescription]);
    
}



#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FoodCell"];
    
    
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FoodCell"];
    }
    
    UILabel *orderLabel = (UILabel*) [cell viewWithTag:100];
    orderLabel.text = [[object objectForKey:@"numberOrder"]stringValue];
    
    UILabel *dateOrderLabel = (UILabel*) [cell viewWithTag:101];
    NSString *dateOrderString = [NSDateFormatter localizedStringFromDate:[object objectForKey:@"dateOrder"]
                                                               dateStyle:NSDateFormatterShortStyle
                                                               timeStyle:NSDateFormatterNoStyle];
    dateOrderLabel.text = dateOrderString;
    
    
    
    return cell;
}






- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSString *categoryFoodName = [self headerForCategory1:indexPath.section];
    NSArray *rowIndecesInSection = [self.sections objectForKey:categoryFoodName];
    NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
    
    if ([self.objects count]){
        return [self.objects objectAtIndex:[rowIndex intValue]];
    }
    return self.sectionOrder ;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@" ========= %d", self.sectionOrder.allKeys.count);
    
    return self.sectionOrder.allKeys.count;
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSString *categoryFoodName = [self headerForCategory1:section];
    //  NSArray *rowIndecesInSection = [self.sections objectForKey:categoryFoodName];
    NSArray *rowIndecesInSection = [self.sections1 objectForKey:categoryFoodName];
    
    NSLog(@"rowIndecesInSection %@ ", rowIndecesInSection);
    
    
     return rowIndecesInSection.count;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *fullNameClient = [self headerForCategory:section];
    return fullNameClient;
}



- (NSString *)headerForCategory1:(NSInteger)section {
    NSLog(@" headerForCategory1  %@ ", [self.sectionOrder objectForKey:[NSNumber numberWithInt:section]]);
    
    return [self.sectionOrder objectForKey:[NSNumber numberWithInt:section]];
}



- (NSString *)headerForCategory:(NSInteger)section {
    //return [self.sectionOrder objectForKey:[NSNumber numberWithInt:section]];
    NSString *fullName;
    NSString *clientID = [self.sectionOrder objectForKey:[NSNumber numberWithInt:section]];
    
    if ([clientID isEqualToString:@"clientName"]) {
        fullName  = clientID;
    } else {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Client"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"clientID == %@", clientID]];
        
        NSError *error = nil;
        NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];
        fullName =[NSString stringWithFormat:@"%@ %@", [[[results objectAtIndex:0] valueForKey:@"firstName"] description] , [[[results objectAtIndex:0] valueForKey:@"lastName"] description]];
    }
    
    return fullName;
}








#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
   // PFObject *selectObject = [self.objects objectAtIndex: [self.tableView indexPathForCell:sender].row];
   //    NSString *numberOrder = [[selectObject  objectForKey:@"numberOrder"]stringValue];
    
    UILabel *orderLabel = (UILabel*) [sender viewWithTag:100];
    NSString *numberOrder = orderLabel.text;
    
 
    
    OrderClienController *controller = (OrderClienController *)[[segue destinationViewController] topViewController];
    [controller setNumberOrder :numberOrder];
}




@end
