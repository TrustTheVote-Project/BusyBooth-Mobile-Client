//
//  PastPollingTableViewController.m
//  
//  Created by Krishna Bharathala on 2/21/16.
//
//

#import "PastPollingTableViewController.h"

#import "WaitTimeTableViewCell.h"
#import "SmallWaitTime.h"
#import "LargeWaitTime.h"

@interface PastPollingTableViewController ()

@property (nonatomic, strong) NSArray* hours_array;

@end

@implementation PastPollingTableViewController

-(id) init {
    self = [super init];
    if (self) {
        self.title = @"Past Poll Times";
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    self.tableView.tableFooterView = [UIView new];
    [self.tableView setUserInteractionEnabled: NO];
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:revealController
                                                                        action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = mainColor;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self getHours];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int time = 60;
    int wait = 0;
    
    if(indexPath.row != 0) {
        long i = indexPath.row - 1;
        if(i < self.hours_array.count) {
            time = [[self.hours_array[i] objectForKey:@"hour"] intValue];
            wait = [[self.hours_array[i] objectForKey:@"time"] intValue];
        }
    }
    
    if(indexPath.row == 0) {
        static NSString *cellIdentifier = @"HeaderCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        cell.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:22.0/255.0 blue:47.0/255.0 alpha:1.0];
        cell.textLabel.text = @"The approximate wait time to vote is";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        return cell;
        
    } else if(indexPath.row == 1) {
        return [[LargeWaitTime alloc] initWithReuseIdentifier:nil time:time wait:wait];
    } else {
        return [[SmallWaitTime alloc] initWithReuseIdentifier:nil time:time wait:wait];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        return 57;
    } else if(indexPath.row == 1) {
        return 214;
    } else {
        return 42;
    }
    
}

- (void)getHours {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"Loading Wait Times!"];
    });
    NSString *post = @"";
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@/history_wait/%@", Domain,
                     [[NSUserDefaults standardUserDefaults] objectForKey:@"boothID"]];

    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =
        [session dataTaskWithRequest:request
                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *hours = [NSJSONSerialization JSONObjectWithData:data
                                                                options:kNilOptions
                                                                  error:&error];

            if([[hours objectForKey:@"code"] integerValue] == 0) {
                self.hours_array = [hours objectForKey:@"data"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [SVProgressHUD dismiss];
                });
            } else {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
                  [SVProgressHUD showErrorWithStatus:@"Error loading information. Please try again later."];
              });
            }
          }];
    [dataTask resume];
}

@end
