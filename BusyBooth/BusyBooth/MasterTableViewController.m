//
//  MasterTableViewController.m
//  BusyBooth
//
//  Created by Krishna Bharathala on 9/4/15.
//  Copyright © 2015 Krishna Bharathala. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterTableViewController.h"

#import "MapViewController.h"
#import "PastPollingTableViewController.h"
#import "PollingPlaceViewController.h"

@interface MasterTableViewController ()

typedef NS_ENUM(NSUInteger, MasterTableViewRowType) {
  MasterTableViewPollingPlace,
  MasterTableViewRowTypeHome,
  MasterTableViewPastPolling,
  MasterTableViewRowTypeCount,
};

@property(nonatomic, strong) NSArray *viewControllerArray;
@property(nonatomic, strong) NSArray *iconArray;
@property(nonatomic, retain) UILabel *notificationLabel;
@property(nonatomic) NSInteger currRow;

@end

@implementation MasterTableViewController

@synthesize rearTableView = _rearTableView;

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [self.revealViewController.frontViewController.view setUserInteractionEnabled:NO];
  [self.revealViewController.view
       addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.revealViewController.frontViewController.view setUserInteractionEnabled:YES];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"";
  self.tableView.tableFooterView = [UIView new];

  self.tableView.bounces = NO;

  self.navigationController.navigationBar.barTintColor = mainColor;

  MapViewController *mainVC = [[MapViewController alloc] init];
  PollingPlaceViewController *pollVC = [[PollingPlaceViewController alloc] init];
  PastPollingTableViewController *pastVC = [[PastPollingTableViewController alloc] init];

  pollVC.masterVC = self;

  self.viewControllerArray = @[pollVC, mainVC, pastVC];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return MasterTableViewRowTypeCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }

    if (indexPath.row < MasterTableViewRowTypeCount) {
        UIViewController *currViewController = [self.viewControllerArray objectAtIndex:indexPath.row];
        cell.textLabel.text = currViewController.title;
    }
    
    cell.contentView.backgroundColor =
        indexPath.row == self.currRow ? [UIColor lightGrayColor] : [UIColor whiteColor];

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  SWRevealViewController *revealController = self.revealViewController;

  if (indexPath.row == self.currRow) {
    [revealController setFrontViewPosition:FrontViewPositionLeft animated:YES];
    return;
  } else if (indexPath.row < MasterTableViewRowTypeCount) {
    UIViewController *newFrontController =
        [self.viewControllerArray objectAtIndex:indexPath.row];

    UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:newFrontController];
    [revealController pushFrontViewController:navigationController animated:YES];

    NSIndexPath *path = [NSIndexPath indexPathForRow:self.currRow inSection:0];
    [tableView cellForRowAtIndexPath:path].contentView.backgroundColor = [UIColor clearColor];
    [tableView cellForRowAtIndexPath:indexPath].contentView.backgroundColor =
        [UIColor lightGrayColor];

    self.currRow = indexPath.row;
  }
}

- (void)presentTimes {
  NSIndexPath *path = [NSIndexPath indexPathForRow:self.currRow inSection:0];
  [self.tableView cellForRowAtIndexPath:path].contentView.backgroundColor = [UIColor whiteColor];
  NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:MasterTableViewPastPolling inSection:0];
  [self.tableView cellForRowAtIndexPath:tempIndexPath].contentView.backgroundColor =
      [UIColor lightGrayColor];
  self.currRow = MasterTableViewPastPolling;

  UIViewController *newFrontController =
      [self.viewControllerArray objectAtIndex:MasterTableViewPastPolling];
  UINavigationController *navigationController =
      [[UINavigationController alloc] initWithRootViewController:newFrontController];
  [self.revealViewController pushFrontViewController:navigationController animated:YES];
}

- (void)presentMapView {
  NSIndexPath *path = [NSIndexPath indexPathForRow:self.currRow inSection:0];
  [self.tableView cellForRowAtIndexPath:path].contentView.backgroundColor = [UIColor whiteColor];
  NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:MasterTableViewRowTypeHome inSection:0];
  [self.tableView cellForRowAtIndexPath:tempIndexPath] .contentView.backgroundColor =
      [UIColor lightGrayColor];
  self.currRow = MasterTableViewRowTypeHome;

  UIViewController *newFrontController =
    [self.viewControllerArray objectAtIndex:MasterTableViewRowTypeHome];
  UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:newFrontController];
  [self.revealViewController pushFrontViewController:navigationController animated:YES];
}

@end
