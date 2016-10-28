//
//  SignUpViewController.m
//  BusyBooth
//
//  Created by Krishna Bharathala on 1/18/16.
//  Copyright © 2016 Krishna Bharathala. All rights reserved.
//

#include <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"
#import "SignUpViewController.h"

@interface SignUpViewController ()

@property (strong, nonatomic) UITextField *firstNameField;
@property (strong, nonatomic) UITextField *lastNameField;
@property (strong, nonatomic) UITextField *DOBField;
@property (strong, nonatomic) UITextField *addressField;
@property (strong, nonatomic) UITextField *zipCodeNumberField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = mainColor;

  CGFloat width = self.view.frame.size.width;
  CGFloat height = self.view.frame.size.height;

  UIImageView *logoImage = [[UIImageView alloc]
      initWithImage:[UIImage imageNamed:@"Oset_Logo2.png"]];
  [logoImage setFrame:CGRectMake(0, 0, 150, 150)];
  [logoImage setCenter:CGPointMake(width / 2, height * 2 / 7)];
  [logoImage setBackgroundColor:[UIColor clearColor]];
  [self.view addSubview:logoImage];
    
    UIButton *viewWaitTimeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [viewWaitTimeButton setFrame:CGRectMake(0, 0, 240, 40)];
    [viewWaitTimeButton setTitleColor:mainColor forState:UIControlStateNormal];
    [viewWaitTimeButton setBackgroundColor:[UIColor whiteColor]];
    [viewWaitTimeButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [viewWaitTimeButton setCenter:CGPointMake(width / 2, height * 6 / 7)];
    [viewWaitTimeButton addTarget:self
                           action:@selector(signup)
                 forControlEvents:UIControlEventTouchUpInside];
    viewWaitTimeButton.layer.cornerRadius = 8;
    [self.view addSubview:viewWaitTimeButton];


  self.firstNameField = [[UITextField alloc] init];
  [self.firstNameField setFrame:CGRectMake(0, 0, 240, 30)];
  [self.firstNameField setPlaceholder:@"First Name"];
  [self.firstNameField setCenter:CGPointMake(width / 2, height * 3 / 7)];
  [self.firstNameField setBorderStyle:UITextBorderStyleRoundedRect];
  [self.firstNameField setDelegate:self];
  self.firstNameField.autocorrectionType = UITextAutocorrectionTypeNo;
  self.firstNameField.keyboardType = UIKeyboardTypeASCIICapable;
  [self.view addSubview:self.firstNameField];

  self.lastNameField = [[UITextField alloc] init];
  [self.lastNameField setFrame:CGRectMake(0, 0, 240, 30)];
  [self.lastNameField setPlaceholder:@"Last Name"];
  [self.lastNameField setCenter:CGPointMake(width / 2, height * 1 / 2)];
  [self.lastNameField setBorderStyle:UITextBorderStyleRoundedRect];
  [self.lastNameField setDelegate:self];
  self.lastNameField.autocorrectionType = UITextAutocorrectionTypeNo;
  self.lastNameField.keyboardType = UIKeyboardTypeASCIICapable;
  [self.view addSubview:self.lastNameField];

  self.DOBField = [[UITextField alloc] init];
  [self.DOBField setFrame:CGRectMake(0, 0, 240, 30)];
  [self.DOBField setPlaceholder:@"Date of Birth: MM/DD/YYYY"];
  [self.DOBField setCenter:CGPointMake(width / 2, height * 4 / 7)];
  [self.DOBField setBorderStyle:UITextBorderStyleRoundedRect];
  [self.DOBField setDelegate:self];
  [self.view addSubview:self.DOBField];

  self.addressField = [[UITextField alloc] init];
  [self.addressField setFrame:CGRectMake(0, 0, 240, 30)];
  [self.addressField setPlaceholder:@"Driver's License ID #"];
  [self.addressField setCenter:CGPointMake(width / 2, height * 9 / 14)];
  [self.addressField setBorderStyle:UITextBorderStyleRoundedRect];
  [self.addressField setDelegate:self];
  [self.view addSubview:self.addressField];

  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(dismissKeyboard)];

  [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [self.firstNameField resignFirstResponder];
    [self.lastNameField resignFirstResponder];
    [self.DOBField resignFirstResponder];
    [self.addressField resignFirstResponder];
    [self.zipCodeNumberField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
  [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
  [self animateTextField:textField up:NO];
}

- (void)animateTextField:(UITextField *)textField up:(BOOL)up {
  const int movementDistance = 80;      // tweak as needed
  const float movementDuration = 0.3f;  // tweak as needed

  int movement = (up ? -movementDistance : movementDistance);

  [UIView beginAnimations:@"anim" context:nil];
  [UIView setAnimationBeginsFromCurrentState:YES];
  [UIView setAnimationDuration:movementDuration];
  self.view.frame = CGRectOffset(self.view.frame, 0, movement);
  [UIView commitAnimations];
}

- (NSString *)sha256HashForFirstName:(NSString *)fName
                            lastName:(NSString *)lName
                                 DOB:(NSString *)DOB
                             address:(NSString *)address {
    
  NSString *number = [[address componentsSeparatedByString:@" "] firstObject];
  const char *str = [[NSString stringWithFormat:@"%@%@%@%@", fName, lName, DOB, number] UTF8String];
    NSLog(@"%s", str);
  unsigned char result[CC_SHA256_DIGEST_LENGTH];
  CC_SHA256(str, strlen(str), result);

  NSMutableString *ret =
      [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
  for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
    [ret appendFormat:@"%02x", result[i]];
  }
  return ret;
}

- (void)signup {
    
    [SVProgressHUD showWithStatus:@"Checking Information"];
    
  NSString *hashValue = [self sha256HashForFirstName:self.firstNameField.text
                                            lastName:self.lastNameField.text
                                                 DOB:self.DOBField.text
                                             address:self.addressField.text];

  NSString *post = [NSString stringWithFormat:@"hashVal=%@", hashValue];
  NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    [request setURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@/validate_user", Domain]]];
  [request setHTTPMethod:@"POST"];
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:postData];

  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionDataTask *dataTask = [session
      dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response,
                            NSError *error) {
          NSDictionary *loginSuccessful = [NSJSONSerialization JSONObjectWithData:data
                                                                          options:kNilOptions
                                                                            error:&error];
            
          if ([[loginSuccessful objectForKey:@"code"] integerValue] == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{ [SVProgressHUD showErrorWithStatus:
                @"Signup Failed. Please check that you have entered your information correctly."];
            });

          } else {
              NSString *address = [[loginSuccessful objectForKey:@"data"] objectForKey:@"address"];
              NSString *boothZip = [[loginSuccessful objectForKey:@"data"] objectForKey:@"zip"];
              NSString *boothID = [[loginSuccessful objectForKey:@"data"] objectForKey:@"id"];
              NSString *isAdmin = [[loginSuccessful objectForKey:@"data"] objectForKey:@"is_admin"];
              
              [[NSUserDefaults standardUserDefaults] setObject:address forKey:@"boothAddress"];
              [[NSUserDefaults standardUserDefaults] setObject:boothZip forKey:@"boothZip"];
              [[NSUserDefaults standardUserDefaults] setObject:boothID forKey:@"boothID"];
              [[NSUserDefaults standardUserDefaults] setObject:isAdmin forKey:@"isAdmin"];
              
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
              [SVProgressHUD showWithStatus:@"Loading Booth Information"];
              [APPDELEGATE presentSWController];
            });
          }
        }];
  [dataTask resume];
}

- (void)noLogin {
    [APPDELEGATE presentSWController];
}

@end
