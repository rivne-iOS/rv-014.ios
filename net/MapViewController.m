//
//  MapViewController.m
//  net
//
//  Created by Admin on 11.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import "MapViewController.h"
#import "Issue.h"
#import "LogInViewController.h"
#import "NetworkDataSorce.h"
#import "IssueCategory.h"
#import "IssueHistoryViewController.h"
#import "IssueCategory.h"
#import "CurrentItems.h"

#import "DescriptionViewController.h"
#import "UIColor+Bawl.h"
@import GoogleMaps;
@import MobileCoreServices;

static NSString * const GOOGLE_WEB_API_KEY = @"AIzaSyB7InJ3J2AoxlHjsYtde9BNawMINCaHykg";
static NSString * const DOMAIN_NAME_ALL_ISSUES = @"https://bawl-rivne.rhcloud.com/issue/all";
static NSString * const DOMAIN_NAME_GOOGLE_PLACE_INFO = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%d&key=%@";
static NSString * const DOMAIN_NAME_ALL_CATEGORIES = @"https://bawl-rivne.rhcloud.com/categories/all";
static NSString * const DOMAIN_NAME_ADD_ISSUE = @"https://bawl-rivne.rhcloud.com/issue";
static NSString * const DOMAIN_NAME_ADD_ATTACHMENT = @"https://bawl-rivne.rhcloud.com/image/add/issue";

static NSInteger const HTTP_RESPONSE_CODE_OK = 200;
static double const MAP_REFRESHING_INTERVAL = 120.0;

@interface MapViewController () <GMSMapViewDelegate, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (nonatomic)BOOL isMarkerSelected;
@property (assign, nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic) BOOL userLogined;
@property (strong, nonatomic) UIImage *attachmentImage;
@property (strong, nonatomic) NSString *attachmentFilename;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bowl";
    self.isMarkerSelected = NO;
    self.dataSorce = [[NetworkDataSorce alloc] init];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor bawlRedColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self checkCurrentUser];

    self.scrollViewLeadingConstraint.constant = CGRectGetWidth(self.mapView.bounds);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.addingIssueViewHeightConstraint.constant = screenRect.size.height;
    
    self.tabBarController.delegate = self;
    [self hideTabBar];
    [self customizeTabBar];
    [self createAndShowMap];
    [self addBorderColor];
    [self customiseProgressBarView];
    [self requestCategories];
}


-(void)checkCurrentUser
{
    
    NSDictionary *userDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"userDictionary"];
    if(userDictionary!=nil)
    {
        self.navigationItem.rightBarButtonItem.title = @"Log in...";
        [self.dataSorce requestLogInWithUser:[userDictionary objectForKey:@"LOGIN"]
                                     andPass:[userDictionary objectForKey:@"PASSWORD"]
                    andViewControllerHandler:^(User *resUser)
         {
                 dispatch_async(dispatch_get_main_queue(), ^ {
                     self.currentUser = resUser;
                     [CurrentItems sharedItems].user = resUser;
                 });
         } andErrorHandler:^(NSError *error) {
             // error!
         }];
    }
    else
    {
        self.currentUser = nil; // sharedItems.user is already nil;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if(self.currentUser==nil)
    {
        self.currentUser = [CurrentItems sharedItems].user;
    }
    
    if([self isMarkerSelected])
        self.tabBarController.tabBar.hidden = NO;
    
    [self renewMap];
    
    [self.timerForMapRenew invalidate];

    self.timerForMapRenew = [NSTimer scheduledTimerWithTimeInterval:MAP_REFRESHING_INTERVAL
                                     target:self
                                   selector:@selector(renewMapWithNSTimer:)
                                   userInfo:nil
                                    repeats:YES];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:self.timerForMapRenew forMode: NSDefaultRunLoopMode];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.timerForMapRenew invalidate];
}

-(void)setCurrentUser:(User *) user
{
    _currentUser = user;
    if(user == nil)
    {
        self.title = [NSString stringWithFormat:@"Bawl"];
        self.navigationItem.rightBarButtonItem.title = @"Log In";
        self.userLogined=NO;

    }
    else
    {
        self.title = [NSString stringWithFormat:@"Bawl(%@)", user.name];
        [self.tabBarController.tabBar.items objectAtIndex:0].title = @"Location";
        self.navigationItem.rightBarButtonItem.title = @"Sign Out";
        self.userLogined = YES;
    }
}

- (IBAction)sequeToLogInButton:(UIBarButtonItem *)sender {
    
    
    if (!self.userLogined)
    {
        self.tabBarController.tabBar.hidden = YES;
        [self performSegueWithIdentifier:@"fromMapToLogIn" sender:self];
    }
    else
    {
        [self.dataSorce requestSignOutWithHandler:^(NSString *stringAnswer) {
            dispatch_async(dispatch_get_main_queue(), ^{
            
            if([stringAnswer isEqualToString:[@"Bye " stringByAppendingString:self.currentUser.name]])
            {
                // alert - good
                self.title = [NSString stringWithFormat:@"Bowl"];
                self.navigationItem.rightBarButtonItem.title = @"Log In";
                self.currentUser=nil;
                [[NSUserDefaults standardUserDefaults] objectForKey:@"userDictionary"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log Out"
                                                                message:@"You loged out successfully!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                // alert - bad
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log Out"
                                                                message:[@"Something has gone wrong! (server answer: )" stringByAppendingString:stringAnswer]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];

            }
            });
        } andErrorHandler:^(NSError *error) {
            // alert - bad
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log Out"
                                                            message:@"Problem with internet connection"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        }];
        
    }
}

#pragma mark Map
-(void)createAndShowMap
{
//    50.619020, 26.252073
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:50.619020
                                                            longitude:26.252073
                                                                 zoom:12];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    
    [self.tabBarController.tabBar setHidden:YES];
}

#pragma mark Requests
-(void)requestIssues
{
        NSURL *url = [NSURL URLWithString:DOMAIN_NAME_ALL_ISSUES];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
        [[[NSURLSession sharedSession]dataTaskWithRequest:request
                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                            if (data.length > 0 && connectionError == nil){
                                        
                                                NSArray *issuesDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:0                                                                                                    error:NULL];
                                                
                                                NSMutableArray <Issue*> *issuesClassArray = [[NSMutableArray alloc] init];
                                                for (NSDictionary *issue in issuesDictionaryArray) {
                                                    [issuesClassArray addObject:[[Issue alloc] initWithDictionary:issue]];
                                                }
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                    [self.mapView clear];
                                                    
                                                    for (Issue *issue in issuesClassArray) {
                                                        if ([issue.status isEqualToString:@"TO_RESOLVE"] || [issue.status isEqualToString:@"APPROVED"]
                                                            || (self.currentUser.role==ADMIN || self.currentUser.role==MANAGER)
                                                            ){
                                                            GMSMarker *marker = [[GMSMarker alloc] init];
                                                            marker.position = CLLocationCoordinate2DMake(issue.getLatitude, issue.getLongitude);
                                                            marker.userData = issue;
                                                            marker.title = issue.name;
                                                            marker.icon = [self changeIconColor:issue];
                                                            marker.map = self.mapView;
                                                        }
                                                    }
                                                });
                                            } else {
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                                                                message:@"Troubles with connection!"
                                                                                               delegate:nil
                                                                                      cancelButtonTitle:@"OK"
                                                                                      otherButtonTitles:nil];
                                                [alert show];
                                            }
                                        }] resume];
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [self.tabBarController.tabBar setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^(void){
        [self showTabBar];
        [self.view layoutIfNeeded];
        
    }];
    self.isMarkerSelected = YES;
    
    CurrentItems *cItems = [CurrentItems sharedItems];
    cItems.issueImage = nil;
    NSLog(@"currents issue image is nil");
    cItems.issue = marker.userData;
    
    return NO;
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.isMarkerSelected = NO;
    [UIView animateWithDuration:0.5 animations:^(void){
        [self hideTabBar];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished){
        if (finished == YES){
            [self.tabBarController.tabBar setHidden:YES];
        }
    }];
}

#pragma mark Tab Bar
-(void)mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    // Only logged one can add new issue
    if (self.currentUser != nil){
        self.mapView.selectedMarker = nil;
        [self requestGoogleApiPlace:coordinate];
        
        if (self.attachmentImage != nil)
            [self.attachmentProgressView setProgress:1.0 animated:NO];
        
        [UIView animateWithDuration:0.5 animations:^(void){
            self.scrollViewLeadingConstraint.constant = 0;
            [self hideTabBar];
            [self.view layoutIfNeeded];
        }];
    }
}

-(void)requestGoogleApiPlace:(CLLocationCoordinate2D)coordinate
{
    NSString *urlString = [[NSString alloc] initWithFormat:DOMAIN_NAME_GOOGLE_PLACE_INFO,
                           coordinate.latitude,
                           coordinate.longitude,
                           1,
                           GOOGLE_WEB_API_KEY];
    self.currentLocation = coordinate;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[[NSURLSession sharedSession]dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                        if (data.length > 0 && connectionError == nil)
                                        {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                self.tapLocationLabel.numberOfLines = 2;
                                                self.tapLocationLabel.lineBreakMode = NSLineBreakByCharWrapping;
                                                self.tapLocationLabel.text = @"";
                                                self.tapLocationLabel.text = [self.tapLocationLabel.text stringByAppendingFormat:@"Location of issue:\n%@, %@",
                                                                              [self takeVicinityFromGoogleApiPlace:data],
                                                                              [self takeStreetFromGoogleApiPlace:data]];
                                            });
                                        }
                                    }] resume];

}

-(NSString *)takeStreetFromGoogleApiPlace:(NSData *)data
{
    NSDictionary *placeDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSArray *resultsArray = [placeDictionary valueForKey:@"results"];
    NSDictionary *locationDictionary = [resultsArray objectAtIndex:0];
    NSString *street = [locationDictionary valueForKey:@"name"];
    return street;
    
}

-(NSString *)takeVicinityFromGoogleApiPlace:(NSData *)data
{
    NSDictionary *placeDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSArray *resultsArray = [placeDictionary valueForKey:@"results"];
    NSDictionary *locationDictionary = [resultsArray objectAtIndex:0];
    NSString *vicinity = [locationDictionary valueForKey:@"vicinity"];
    return vicinity;
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]] && [viewController.restorationIdentifier isEqualToString:@"description"]){
        UINavigationController *destController = (UINavigationController *)viewController;
        DescriptionViewController *descriptionVC = (DescriptionViewController *)destController.topViewController;
        descriptionVC.mapViewControllerDelegate = self;
        descriptionVC.title = self.title;
    }
    else if ([viewController isKindOfClass:[UINavigationController class]] && [viewController.restorationIdentifier isEqualToString:@"history"]){
        UINavigationController *destController = (UINavigationController *)viewController;
        IssueHistoryViewController *issueHistoryViewController = (IssueHistoryViewController *)destController.topViewController;
        issueHistoryViewController.title = self.title;
    }
    return YES;
}

-(void)showTabBar
{
    CGRect tabFrame = self.tabBarController.tabBar.frame;
    tabFrame.origin.y = self.view.frame.size.height - 48;
    self.tabBarController.tabBar.frame = tabFrame;
}

-(void)hideTabBar
{
    CGRect tabFrame = self.tabBarController.tabBar.frame;
    tabFrame.origin.y = self.view.frame.size.height;
    self.tabBarController.tabBar.frame = tabFrame;
}

-(void)customizeTabBar
{
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem *tabBarItemLocation = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItemDescription = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItemHistory = [tabBar.items objectAtIndex:2];
    
    UIImage *locationInactiveImg = [UIImage imageNamed:@"location_inactive"];
    UIImage *scaledLocationInactiveImg = [[UIImage imageWithCGImage:[locationInactiveImg CGImage] scale:locationInactiveImg.scale * 3.5 orientation:locationInactiveImg.imageOrientation] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *locationActiveImg = [UIImage imageNamed:@"location_active"];
    UIImage *scaledLocationActiveImg = [[UIImage imageWithCGImage:[locationActiveImg CGImage] scale:locationActiveImg.scale * 3.5 orientation:locationActiveImg.imageOrientation] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *descInactiveImg = [UIImage imageNamed:@"desc_inactive"];
    UIImage *scaledDescInactiveImg = [[UIImage imageWithCGImage:[descInactiveImg CGImage] scale:descInactiveImg.scale * 3.5 orientation:descInactiveImg.imageOrientation] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *descActiveImg = [UIImage imageNamed:@"desc_active"];
    UIImage *scaledDescActiveImg = [[UIImage imageWithCGImage:[descActiveImg CGImage] scale:descActiveImg.scale * 3.5 orientation:descActiveImg.imageOrientation] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *historyInactiveImg = [UIImage imageNamed:@"history_inactive"];
    UIImage *scaledHistoryInactiveImg = [[UIImage imageWithCGImage:[historyInactiveImg CGImage] scale:historyInactiveImg.scale * 3.5 orientation:historyInactiveImg.imageOrientation] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImage *historyActiveImg = [UIImage imageNamed:@"history_active"];
    UIImage *scaledHistoryActiveImg = [[UIImage imageWithCGImage:[historyActiveImg CGImage] scale:historyActiveImg.scale * 3.5 orientation:historyActiveImg.imageOrientation] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItemLocation = [tabBarItemLocation initWithTitle:@"Location" image:scaledLocationInactiveImg selectedImage:scaledLocationActiveImg];
    tabBarItemDescription = [tabBarItemDescription initWithTitle:@"Description" image:scaledDescInactiveImg selectedImage:scaledDescActiveImg];
    tabBarItemHistory = [tabBarItemHistory initWithTitle:@"History" image:scaledHistoryInactiveImg selectedImage:scaledHistoryActiveImg];
    
    [tabBarItemLocation setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.78 green:0.784 blue:0.784 alpha:1] /*#c7c8c8*/}
                                             forState:UIControlStateNormal];
    [tabBarItemLocation setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor bawlRedColor] /*#e94f68*/ }
                                             forState:UIControlStateSelected];
    [tabBarItemDescription setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.78 green:0.784 blue:0.784 alpha:1] /*#c7c8c8*/}
                               forState:UIControlStateNormal];
    [tabBarItemDescription setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor bawlRedColor] /*#e94f68*/}
                               forState:UIControlStateSelected];
    [tabBarItemHistory setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.78 green:0.784 blue:0.784 alpha:1] /*#c7c8c8*/}
                               forState:UIControlStateNormal];
    [tabBarItemHistory setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor bawlRedColor] /*#e94f68*/ }
                               forState:UIControlStateSelected];
}

-(void)animateTabsSwitching:(UIViewController *)viewController
{
    NSUInteger controllerIndex = [self.tabBarController.viewControllers indexOfObject:viewController];
    
    UIView *fromView = self.tabBarController.selectedViewController.view;
    UIView *toView = [viewController view];
    [UIView transitionFromView:fromView
                            toView:toView
                          duration:0.5
                           options:(controllerIndex > self.tabBarController.selectedIndex ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight)
                        completion:^(BOOL finished) {
                            if (finished) {
                                self.tabBarController.selectedIndex = controllerIndex;
                            }
                        }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.categoryClassArray.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.categoryClassArray[row] name];
}

-(void)requestCategories
{
    NSURL *url = [NSURL URLWithString:DOMAIN_NAME_ALL_CATEGORIES];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[[NSURLSession sharedSession]dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                        if (data.length > 0 && connectionError == nil)
                                        {
                                            NSArray *categoryDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:0                                                                                                   error:NULL];
                                            
                                            self.categoryClassArray = [[NSMutableArray alloc] init];
                                            
                                            for (NSDictionary *category in categoryDictionaryArray) {
                                                [self.categoryClassArray addObject:[[IssueCategory alloc] initWithDictionary:category]];
                                            }
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self.categoryPicker reloadAllComponents];
                                            }
                                                           );}
                                    }] resume];
}

-(void)addBorderColor
{
    [self.descriptionTextView.layer setBorderColor:[[UIColor bawlRedColor05alpha] CGColor]];
    [self.descriptionTextView.layer setBorderWidth:1.0];
    [self.nameTextField.layer setBorderColor:[[UIColor bawlRedColor05alpha] CGColor]];
    [self.nameTextField.layer setBorderWidth:1.0];
    [self.categoryPicker.layer setBorderColor:[[UIColor bawlRedColor05alpha] CGColor]];
    [self.categoryPicker.layer setBorderWidth:1.0];
    [self.attachmentTextField.layer setBorderColor:[[UIColor bawlRedColor05alpha] CGColor]];
    [self.attachmentTextField.layer setBorderWidth:1.0];
}

#pragma mark Button events
- (IBAction)buttonBackPressed:(id)sender
{
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [UIView animateWithDuration:0.5 animations:^(void){
        self.scrollViewLeadingConstraint.constant = CGRectGetWidth(self.mapView.bounds);
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)buttonAddPressed:(id)sender
{
    if (![self checkFields]){
        [self showAlert:@"Validation error" withMessage:@"Fill all fields!"];
        return;
    }
    [self requestAddingNewIssue:[self getJsonFromAddingNewIssueView]];
//    [self requestAddingNewIssue:[self getJsonFromAddingNewIssueView]];
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [UIView animateWithDuration:0.5 animations:^(void){
        self.scrollViewLeadingConstraint.constant = CGRectGetWidth(self.mapView.bounds);
        [self.view layoutIfNeeded];
    }];
}

-(NSDictionary *)getJsonFromAddingNewIssueView
{
    //    JSON example
    //    {
    //        "name": "Huge traffic jam",
    //        "desc": "Many cars stucked in the long row.",
    //        "point": "LatLng(50.55845, 26.3072)",
    //        "status": "NEW",
    //        "category": 3,
    //    }
    NSArray *addIssueValues = [[NSArray alloc] initWithObjects:
                               self.nameTextField.text,
                               self.descriptionTextView.text,
                               [[NSString alloc] initWithFormat:@"LatLng(%f, %f)", self.currentLocation.latitude, self.currentLocation.longitude],
                               @"NEW",
                               [NSNumber numberWithInt:[self.categoryPicker selectedRowInComponent:0]],
                               self.attachmentFilename,
                               nil];
    NSArray *addIssueKeys = [[NSArray alloc] initWithObjects:
                             @"name",
                             @"desc",
                             @"point",
                             @"status",
                             @"category",
                             @"attach",
                             nil];
    return [[NSDictionary alloc] initWithObjects:addIssueValues forKeys:addIssueKeys];
}

-(void)requestAddingNewIssue:(NSDictionary *)jsonDictionary
{
    // 1
    NSURL *url = [NSURL URLWithString:DOMAIN_NAME_ADD_ISSUE];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // 2
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // 3
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                   options:kNilOptions error:&error];
    if (!error) {
        // 4
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                   fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                                       if ([httpResponse statusCode] != HTTP_RESPONSE_CODE_OK){
                                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                                                                                           message:@"Something has gone wrong! (we have ansswer from server, but it's incorrect)"
                                                                                                                          delegate:nil
                                                                                                                 cancelButtonTitle:@"I understood"
                                                                                                                 otherButtonTitles:nil];
                                                                           [alert show];
                                                                       } else {
                                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                                               [self renewMap];
                                                                               [self clearAllFields];
                                                                           });
                                                                       }
                                                                   }];
        
        // 5
        [uploadTask resume];
    }
}

//-(void)requestAddingAttachmentToIssue
//{
//    NSURL *url = [NSURL URLWithString:DOMAIN_NAME_ADD_ATTACHMENT];
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
//
//    NSString *boundary = [self generateBoundaryString];
//    
//    // configure the request
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    [request setHTTPMethod:@"POST"];
//    
//    // set content type
//    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
//    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
//    
//    // create body
//    NSData *httpBody = [self createBodyWithBoundary:boundary image:self.attachmentImage fieldName:@"file"];
//    
//    request.HTTPBody = httpBody;
//    
//    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (error) {
//            NSLog(@"Error = %@", error);
//            return;
//        }
//        
//        NSDictionary *attachmentServerResponse = [NSJSONSerialization JSONObjectWithData:data options:0                                                                                                   error:NULL];
//        self.attachmentFilename = attachmentServerResponse[@"filename"];
//        [self requestAddingNewIssue:[self getJsonFromAddingNewIssueView]];
//    }];
//    [task resume];
//}

-(void)renewMap
{
    [self requestIssues];
}

-(void)renewMapWithNSTimer:(NSTimer *)timer
{
    [self requestIssues];
}

-(UIImage *)changeIconColor:(Issue *)issue
{
    if ([issue.status isEqualToString:@"APPROVED"]){
        return [GMSMarker markerImageWithColor:[UIColor greenColor]];
    } else if ([issue.status isEqualToString:@"TO_RESOLVE"]){
        return [GMSMarker markerImageWithColor:[UIColor orangeColor]];
    }
    
    return [GMSMarker markerImageWithColor:[UIColor redColor]];
}

-(void)initializeImagePickerController
{
//    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    [self.addingIssueView addSubview:indicator];
//    indicator.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.addingIssueView addConstraint:[NSLayoutConstraint constraintWithItem:indicator
//                                                                     attribute:NSLayoutAttributeCenterX
//                                                                     relatedBy:NSLayoutRelationEqual
//                                                                        toItem:self.addingIssueView
//                                                                     attribute:NSLayoutAttributeCenterX
//                                                                    multiplier:1.0
//                                                                      constant:0.0]];
//    [self.addingIssueView addConstraint:[NSLayoutConstraint constraintWithItem:indicator
//                                                                     attribute:NSLayoutAttributeCenterY
//                                                                     relatedBy:NSLayoutRelationEqual
//                                                                        toItem:self.addingIssueView
//                                                                     attribute:NSLayoutAttributeCenterY
//                                                                    multiplier:1.0
//                                                                      constant:0.0]];
//    indicator.color = [UIColor blackColor];
//    [self.addingIssueView layoutIfNeeded];
//    [self.view bringSubviewToFront:indicator];
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.attachmentImage = info[UIImagePickerControllerOriginalImage];

    [self.indicator stopAnimating];
    self.addingIssueView.userInteractionEnabled = YES;
    self.attachmentLoadButton.userInteractionEnabled = NO;
    
    [self.attachmentProgressView setProgress:0.0];
    [self.attachmentProgressView setAlpha:1.0];
    [self.attachmentSuccessfullLabel setAlpha:0.0];
    
    [self requestAddingAttachmentToIssueByAfnetworking:self.attachmentImage fieldName:@"file" mimeType:@"image/jpeg" fileName:@"picture_name.jpg"];
    
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

-(IBAction)buttonLoadPressed:(id)sender
{
    self.addingIssueView.userInteractionEnabled = NO;
    [self.indicator startAnimating];

    [self initializeImagePickerController];
}

-(BOOL)checkFields
{
    if ([self.nameTextField.text isEqualToString:@""] |
        [self.descriptionTextView.text isEqualToString:@""] |
        self.attachmentImage == nil)
        return NO;
    else
        return YES;
}

-(void)showAlert:(NSString *)title withMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

//-(NSData *)createBodyWithBoundary:(NSString *)boundary
//                            image:(UIImage *)image
//                        fieldName:(NSString *)fieldName
//{
//    NSMutableData *httpBody = [NSMutableData data];
//    
//    NSData *data = UIImageJPEGRepresentation(image, 1.0);
//    
//    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, @"image_name.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"image/jpeg"] dataUsingEncoding:NSUTF8StringEncoding]];
//    [httpBody appendData:data];
//    [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    return httpBody;
//}
//
//- (NSString *)generateBoundaryString
//{
//    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
//
//}

-(void)clearAllFields
{
    self.nameTextField.text = @"";
    self.descriptionTextView.text = @"";
    [self.categoryPicker selectRow:0 inComponent:0 animated:NO];
    self.attachmentImage = nil;
    self.attachmentFilename = nil;
    [self.attachmentProgressView setProgress:0.0];
    [self.attachmentProgressView setAlpha:1.0];
    [self.attachmentSuccessfullLabel setAlpha:0.0];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    self.scrollViewLeadingConstraint.constant = size.width;
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
}

-(void)requestAddingAttachmentToIssueByAfnetworking:(UIImage *)image
                                          fieldName:(NSString *)fieldName
                                           mimeType:(NSString *)mimeType
                                           fileName:(NSString *)fileName
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:DOMAIN_NAME_ADD_ATTACHMENT parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:fieldName fileName:fileName mimeType:mimeType];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          [self.attachmentProgressView setProgress:uploadProgress.fractionCompleted animated:YES];
                          if (uploadProgress.fractionCompleted == 1.0) {
                              [UIView animateWithDuration:1.0 animations:^(void) {
                                  [self.attachmentProgressView setAlpha:0.0];
                                  [self.attachmentSuccessfullLabel setAlpha:1.0];
                              }];
                              self.attachmentLoadButton.userInteractionEnabled = YES;
                          }
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                      } else {
                          NSLog(@"%@ %@", response, responseObject);
                          self.attachmentFilename = responseObject[@"filename"];
                      }
                  }];
    
    [uploadTask resume];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.indicator stopAnimating];
    self.addingIssueView.userInteractionEnabled = YES;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)customiseProgressBarView
{
    NSArray *grayColors = @[[UIColor grayColor], [UIColor grayColor]];
    
    self.attachmentProgressView.type = YLProgressBarTypeFlat;
    self.attachmentProgressView.progressTintColors = grayColors;
    self.attachmentProgressView.trackTintColor = [UIColor whiteColor];
    self.attachmentProgressView.hideStripes = YES;
    self.attachmentProgressView.progressStretch = NO;
    [self.attachmentProgressView setProgress:0.0f animated:NO];

    CGFloat borderWidth = 1.0f;
    self.attachmentProgressView.frame = CGRectInset(self.attachmentProgressView.frame, -borderWidth, -borderWidth);
    self.attachmentProgressView.layer.borderColor = [UIColor grayColor].CGColor;
    self.attachmentProgressView.layer.borderWidth = borderWidth;
}

@end
