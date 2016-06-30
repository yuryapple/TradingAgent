//
//  FoodList.m
//  FoofList
//
//  Created by  Yury_apple_mini on 3/21/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "CompliteOrderController.h"

@interface CompliteOrderController ()

@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionOrder;
@property (nonatomic, retain) NSMutableDictionary *sections1;

@property (nonatomic, strong) SliderForFooter *sl;
@property (nonatomic ,strong) NSMutableArray * sArray;

@end

@implementation CompliteOrderController



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
    
    _sArray = [NSMutableArray array];
    
    _sl = [[SliderForFooter alloc]init];
    _sl.delegate = self;
    _sl.section = 0;
    [_sArray insertObject:_sl atIndex:0];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


-(void)viewWillAppear:(BOOL)animated{
    [self loadObjects];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)reloadTableWithCurrentSettings {
    self.navigationItem.title = [[NSString stringWithFormat:@"%@ - ", NSLocalizedString([_settingsUserDefault getDefaultNameDeliveryPerson], nil)] stringByAppendingString:NSLocalizedString(@"Delivery", nil)];
    [self loadObjects];
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



#pragma mark -  Fetched results controller

- (PFQuery *)queryForTable
{
    // 365 - days in year
    NSPredicate *predicate = [NSPredicate predicateWithFormat:   @"numberOrder > %d AND numberOrder < %d",
                              [[NSString stringWithFormat:@"%ld00000",(long)[_settingsUserDefault getDefaultOwnerNumber]] integerValue],
                              [[NSString stringWithFormat:@"%ld36700",(long)[_settingsUserDefault getDefaultOwnerNumber]] integerValue]
                              ];
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName  predicate:predicate];
    
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
      // if ([self.objects count] == 0) {
      //   query.cachePolicy = kPFCachePolicyCacheThenNetwork;
      // }
 
    NSDate *currentDate = [NSDate date];
    NSDate *dateAgo = [currentDate dateByAddingTimeInterval:(- 90 * 24 * 60 * 60)];
    
    [query whereKey:@"dateComplete" greaterThanOrEqualTo:dateAgo];
    
    [query orderByAscending:@"clientID"];
    [query addDescendingOrder:@"dateComplete"];
    
    return query;
}



- (void) objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    [self.sections removeAllObjects];
    [self.sectionOrder removeAllObjects];
    [self.sections1 removeAllObjects];
    
    
    NSInteger section = 0;
    NSInteger rowIndex = 0;
    _sArray = [NSMutableArray array];
    
    for (PFObject *object in self.objects) {
        
        NSString *clientID = [object objectForKey:@"clientID"];
        NSString *numberOrder = [object objectForKey:@"dateComplete"] ;
        
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
    
    
    
    for (int i = 0; i < self.sectionOrder.allKeys.count; i++) {
        _sl = [[SliderForFooter alloc]init];
        _sl.delegate = self;
        _sl.days = 1;
        _sl.section = i;
        
        NSLog(@"--------  %d  ", i);
        
        
        [_sArray insertObject:_sl atIndex:i];
    }
    
    NSLog(@"ARRAY  %@  ", _sArray);
    NSLog(@"A  %d  ", _sArray.count);
    
    
    
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
    

    UILabel *dateCompleteLabel = (UILabel*) [cell viewWithTag:102];
    NSString *dateCompliteOrderString = [NSDateFormatter localizedStringFromDate:[object objectForKey:@"dateComplete"]
                                                               dateStyle:NSDateFormatterShortStyle
                                                                timeStyle:NSDateFormatterNoStyle];
    dateCompleteLabel.text = dateCompliteOrderString;
    
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

    
    
     NSLog(@" s Array Complite     %@",_sArray);
    
    
    
    SliderForFooter * slider = [_sArray objectAtIndex:section];
    
    NSLog(@"Section for slider      %d",[ slider section]);
    

    
   // int days =slider.label.text.intValue;
    
    int days = [slider days];
    
  //  NSLog(@"Day      %d",days);
    

    NSDate *currentDate = [NSDate date];
    NSDate *dateAgo = [currentDate dateByAddingTimeInterval:(- days * 24 * 60 * 60)];
    
    
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF >= %@", dateAgo];
    
   // NSLog(@"filter      %@",[rowIndecesInSection filteredArrayUsingPredicate:predicate]);

    
    return [[rowIndecesInSection filteredArrayUsingPredicate:predicate] count];
   
   // return rowIndecesInSection.count;
    
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


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return [[_sArray objectAtIndex:section] view];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    
  //  NSLog(@"A R R A Y %@  ", _sArray);
  //  NSLog(@"A R R A Y COUN %lu  ", (unsigned long)_sArray.count);
    
    return   [[[_sArray objectAtIndex:section] view] bounds].size.height ;
}





#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    UILabel *orderLabel = (UILabel*) [sender viewWithTag:100];
    NSString *numberOrder = orderLabel.text;

    UILabel *dateCreate = (UILabel*) [sender viewWithTag:101];
    NSString *dateCreateOrder = dateCreate.text;
    
    UILabel *dateCompite = (UILabel*) [sender viewWithTag:102];
    NSString *dateCompiteOrder = dateCompite.text;
    
    ViewController *controller = [segue destinationViewController];
    
    [controller setNumberOrder :numberOrder];
    [controller setDateCreateOrder :dateCreateOrder];
    [controller setDateCompiteOrder :dateCompiteOrder];
}



@end