//
//  PollingBoothTableViewController.m
//  BusyBooth
//
//  Created by Krishna Bharathala on 11/4/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#import "PollingBoothTableViewController.h"
#import "AppDelegate.h"

@interface PollingBoothTableViewController ()
                <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property(strong, nonatomic) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation *location;
@property int zipcode;

@property(nonatomic, strong) NSMutableArray *addressArray;

@property(nonatomic, strong) UITableView *tableView;

@end

@implementation PollingBoothTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBar *navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    navbar.barTintColor = mainColor;
    UINavigationItem *navItem = [UINavigationItem alloc];
    navItem.title = @"Choose Voting Location";
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    navbar.titleTextAttributes = navbarTitleTextAttributes;
    [navbar pushNavigationItem:navItem animated:false];
    [self.view addSubview:navbar];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    self.addressArray = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 320, self.view.frame.size.height-50) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *backButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                         style:UIBarButtonItemStyleDone
                                        target:self
                                        action:@selector(back)];
    backButtonItem.tintColor = [UIColor whiteColor];
    navItem.leftBarButtonItem = backButtonItem;
}

-(void) back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.location = [locations objectAtIndex:0];
    [self.locationManager stopUpdatingLocation];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error)) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             self.zipcode = [[[NSString alloc]initWithString:placemark.postalCode] intValue];
             [self updateTable];
         } else {
             [SVProgressHUD dismiss];
             [SVProgressHUD showErrorWithStatus:@"Failed to identify location. Please try again"];
         }
     }];
}

-(void)updateTable {
    NSString *post = [NSString stringWithFormat:@"zip=%d", self.zipcode];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/booths", Domain];
    [request setURL:[NSURL URLWithString: urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =
    [session dataTaskWithRequest:request
               completionHandler:^(NSData *data, NSURLResponse *response,
                                   NSError *error) {
                   
                   NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:kNilOptions
                                                                             error:&error];
                   if([[dataDic objectForKey:@"code"] intValue] == 0) {
                       NSMutableArray *addressArray = [dataDic objectForKey:@"data"];
                       if ([addressArray count] == 0) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [SVProgressHUD showErrorWithStatus:@"Can't find a voting booth in your area."];
                               [self dismissViewControllerAnimated:YES completion:nil];
                           });
                       } else {
                           self.addressArray = addressArray;
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [self.tableView reloadData];
                               [SVProgressHUD dismiss];
                           });
                       }
                   }
               }];
    [dataTask resume];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.addressArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [[self.addressArray objectAtIndex:indexPath.item] objectAtIndex:0];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *address = [[self.addressArray objectAtIndex:indexPath.item] objectAtIndex:0];
    NSString *boothID = [[self.addressArray objectAtIndex:indexPath.item] objectAtIndex:1];
    
    [[NSUserDefaults standardUserDefaults] setObject:address forKey:@"boothAddress"];
    [[NSUserDefaults standardUserDefaults] setObject:boothID forKey:@"boothID"];
    [[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:@"isAdmin"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:nil];
        [SVProgressHUD showWithStatus:@"Loading Booth Information"];
        [APPDELEGATE presentSWController];
    });
    
}

@end
