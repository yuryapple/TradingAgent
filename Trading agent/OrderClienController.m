//
//  OrderClienController.m
//  Trading agent
//
//  Created by  Yury_apple_mini on 3/28/16.
//  Copyright © 2016 MyCompany. All rights reserved.
//

#import "OrderClienController.h"
#import "FoodListController.h"
#import "ProductItemController.h"



@interface OrderClienController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong)  ConvertProducts * convertProd;
@property (assign) BOOL isNew;
@property (assign) BOOL didConvert;


//-(NSString *) headerForOrder;
//-(NSString *) clientIDFromOrder: (NSString *)numberOrder;


-(BOOL) isTempOrderExistIntoCoreData;

@end

@implementation OrderClienController

@synthesize numberOrder = _numberOrder;


- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        _managedObjectContext =[[SharedManagedObjectContext sharedManager] managedObjectContext] ;
        
        _settingsUserDefault =[SharedSettingsUserDefault sharedSettingsUserDefault];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTableWithCurrentCur)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationItem] initWithTitle:_numberOrder];

    
    _convertProd = [[ConvertProducts alloc]init];
    [_convertProd setControllerDelegate:self];
    
    
    if (![self isTempOrderExistIntoCoreData])
    {
        //if order doesn't to Core Data it must do convertParseToCoreData
        _didConvert =NO;
        [_convertProd convertParseToCoreData:_numberOrder];
      
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.leftBarButtonItem = self.editButtonItem;
     self.navigationController.toolbarHidden = NO;
}


-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}


-(BOOL) isTempOrderExistIntoCoreData {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numberOrder = %d",[_numberOrder intValue]];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    request.predicate = predicate;
    NSArray * ordersArray = [[self managedObjectContext] executeFetchRequest:request error:nil];
    
    
    if (ordersArray.count){
        _isNew = YES;
        return _isNew;
    }else{
        _isNew = NO;
        return _isNew;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ConvertProductsDelegate

-(void)convertDidCompliteParseToCoreData{
    NSLog(@"Successfully convert  To CoreData");
    
      _didConvert = YES;
     [self.tableView reloadData];
}



-(void)convertDidCompliteCoreDataToParse{
    [self deleteOrderFromCoreData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"numberOfSectionsInTableView %lu" , [[self.fetchedResultsController sections] count]);
    
     return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    
    NSLog(@"s      Objects       %@", [self.fetchedResultsController description]);
    
    [self saveButtonEnable: [sectionInfo numberOfObjects]];
    return [sectionInfo numberOfObjects];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_isNew || _didConvert) {
        NSString *clientFullName = [self getFullName];
        return clientFullName;
    }
    // wait convert to Core Data (clientFullName is empty)
    return @"";
}



-(NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    double totalSum = 0;
    for (id object in [self.fetchedResultsController fetchedObjects ]){
        totalSum += [[object valueForKey:@"price"] doubleValue] * [[object valueForKey:@"units"]integerValue];
    }
    
    if ([_settingsUserDefault getDefaultCurrencyNumber] == 0 ){
       return  [NSString stringWithFormat:@"%@ %@",  [@(totalSum) stringValue], [_settingsUserDefault getDefaultCurrencySign]];
    } else {
       return  [NSString stringWithFormat:@"%@ %@", [_settingsUserDefault getDefaultCurrencySign],  [@(totalSum) stringValue]];
    }
    
 
}




/*
-(NSString *) clientIDFromOrder: (NSString *)numberOrder {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numberOrder == %d", [numberOrder integerValue]];
    PFQuery *query = [PFQuery queryWithClassName:@"Order" predicate:predicate];
    NSError *error = nil;
    NSArray *client =  [query findObjects:&error];
    
    return [[client objectAtIndex:0] valueForKey:@"clientID"];
}
*/



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}



- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *productID = [object valueForKey:@"objectIDProductParse"];
    
    
    
    
    // GET data from Parse (Image and Name of product)

    PFQuery *query = [PFQuery queryWithClassName:@"FoodProduct"];
    [query getObjectInBackgroundWithId:productID block:^(PFObject * _Nullable product, NSError * _Nullable error) {
        
        
    PFFile *thumbnail = [product  objectForKey:@"foto"];
    PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:100];
    thumbnailImageView.image = [UIImage imageNamed:@"photo-frame.png"];
    thumbnailImageView.file = thumbnail;
    [thumbnailImageView loadInBackground];
    
    
    UILabel *productName = (UILabel*) [cell viewWithTag:101];
    productName.text = [[product valueForKey:@"product"] description];
    
    NSLog(@"^^^^^^^^^^^ %@ ",  [product valueForKey:@"product"] );
        
    }];
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // GET data from CORE DATA
    
    UILabel *productPrice = (UILabel*) [cell viewWithTag:102];
    
    if ([_settingsUserDefault getDefaultCurrencyNumber] == 0 ){
         productPrice.text =  [NSString stringWithFormat:@"%@ %@", [[object valueForKey:@"price"] description] , [_settingsUserDefault getDefaultCurrencySign]];
    } else {
         productPrice.text =  [NSString stringWithFormat:@"%@ %@", [_settingsUserDefault getDefaultCurrencySign],  [[object valueForKey:@"price"] description]];
    }


    
    NSLog(@"^^^^^^^^^^^ %@ ",  [object valueForKey:@"price"] );
    
    
    UILabel *productUnits = (UILabel*) [cell viewWithTag:103];
    productUnits.text = [[object valueForKey:@"units"] description] ;
    

    
    UILabel *productSum = (UILabel*) [cell viewWithTag:104];
    
    if ([_settingsUserDefault getDefaultCurrencyNumber] == 0 ){
        productSum.text =  [NSString stringWithFormat:@"%@ %@", [@([[object valueForKey:@"price"] doubleValue] *  [[object valueForKey:@"units"]integerValue]) stringValue] , [_settingsUserDefault getDefaultCurrencySign]];
    } else {
        productSum.text =  [NSString stringWithFormat:@"%@ %@", [_settingsUserDefault getDefaultCurrencySign],  [@([[object valueForKey:@"price"] doubleValue] *  [[object valueForKey:@"units"]integerValue]) stringValue]];
    }
    
  //  productSum.text = [@([[object valueForKey:@"price"] doubleValue] *  [[object valueForKey:@"units"]integerValue]) stringValue] ;
    
    
      cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
         NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
         NSManagedObjectContext *context = [object managedObjectContext];
         [context deleteObject:object];
         [[SharedManagedObjectContext sharedManager] saveContext];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/





#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    // Clear previous cache
    [NSFetchedResultsController deleteCacheWithName:@"Order"];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OrderProduct" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"price" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"order.numberOrder = %d", [_numberOrder integerValue]];
    [fetchRequest setPredicate:pred];
    
    NSLog(@"                      order.numberOrder == %ld", (long)[_numberOrder integerValue]);
    
    NSError * e = nil;
    
    NSLog(@"                  fetch        %@                         ",[_managedObjectContext executeFetchRequest:fetchRequest error: &e ]);
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:@"Order"];
    
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}



- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}



- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
             [self.tableView reloadData];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
    }
}



#pragma mark - Functionality

-(NSMutableArray *)getListProductsIdInOrder {
    
    NSMutableArray *productsInOrder = [NSMutableArray array];

    for ( NSManagedObject *obj in [self.fetchedResultsController fetchedObjects]){
        [productsInOrder addObject:[obj valueForKey:@"objectIDProductParse"]];
    }
    
    
    NSLog(@"Exist products %@     --------", productsInOrder);
    return  productsInOrder;
}


-(NSManagedObject *) getCurrentOrderFromCore {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"numberOrder = %d",[_numberOrder intValue]];
    NSFetchRequest *requestClientID = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    requestClientID.predicate = predicate;
    NSManagedObject *currentOrder = [[[self managedObjectContext] executeFetchRequest:requestClientID error:nil] objectAtIndex:0];
    return currentOrder;
}



// get client ID
-(NSString *) getClientID {
    NSManagedObject *currentOrder = [self getCurrentOrderFromCore];
    NSString *clientID = [currentOrder valueForKey:@"clientID"];
    return clientID;
}



-(NSString *)getFullName {
    
    NSString *clientID = [self getClientID];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Client"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"clientID == %@", clientID]];
    
    NSError *error = nil;
    NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];
    
    
    NSString *fullName =[NSString stringWithFormat:@"%@ %@", [[[results objectAtIndex:0] valueForKey:@"firstName"] description] , [[[results objectAtIndex:0] valueForKey:@"lastName"] description]];
    
    return fullName;
}


-(void)deleteOrderFromCoreData {
    
    _fetchedResultsController = nil;
    
     NSLog(@"getCurrentOrderFromCore %@", [self getCurrentOrderFromCore] );
    
    [_managedObjectContext deleteObject:[self getCurrentOrderFromCore]];
    
   // NSLog(@"getCurrentOrderFromCore %@", [self getCurrentOrderFromCore] );
    
    [[SharedManagedObjectContext sharedManager] saveContext];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) saveButtonEnable: (NSInteger) totalRecords {
    
    NSArray * buttonArray = self.toolbarItems;
    UIBarButtonItem *saveButton =  [buttonArray objectAtIndex:0];
    if (totalRecords){
        saveButton.enabled = YES;
    }else{
        saveButton.enabled = NO;
    }
}

-(void)reloadTableWithCurrentCur {
    [self.tableView reloadData];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
   if ([[segue identifier] isEqualToString:@"listProducts"]) {
       FoodListController *controller = (FoodListController *)[segue destinationViewController] ;
       
       
         NSLog(@"Exist products %@     --------", [self getListProductsIdInOrder]);
       
       [controller setProductsExistInOrder :[self getListProductsIdInOrder]];
       [controller setNumberOrder : _numberOrder];
   }
    
    if ([[segue identifier] isEqualToString:@"editSelectProduct"]){
        NSManagedObject *editSelectProduct = [self.fetchedResultsController objectAtIndexPath: [self.tableView indexPathForCell:sender]];

        ProductItemController *controller = (ProductItemController *)[segue destinationViewController] ;
        
        [controller setSourceViewControllerName : @"editSelectProduct"];
        [controller setNumberOrder :_numberOrder];
        [controller setSelectProduct : editSelectProduct];
   }
}

- (IBAction)editProductTo:(UIStoryboardSegue *)unwindSegue
{
    if ([[unwindSegue identifier] isEqualToString:@"UnwindEditProductTo"]) {
   //     ProductItemController* controller = unwindSegue.sourceViewController;
   //     [_productsExistInOrder addObject:controller.productId];
   //     [self loadObjects];
    }
}






- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    sender.enabled = NO;
    [self deleteOrderFromCoreData];
}






- (IBAction)saveButton:(UIBarButtonItem *)sender {
    [_convertProd convertCoreDataToParse:_numberOrder forClientID:[self getClientID] withProducts:[self.fetchedResultsController fetchedObjects] forNewOrder: _isNew];
}




@end
