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

#import "DescriptionViewController.h"
@import GoogleMaps;

static NSString * const GOOGLE_WEB_API_KEY = @"AIzaSyB7InJ3J2AoxlHjsYtde9BNawMINCaHykg";
static NSString * const DOMAIN_NAME_ALL_ISSUES = @"https://bawl-rivne.rhcloud.com/issue/all";
static NSString * const DOMAIN_NAME_GOOGLE_PLACE_INFO = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%d&key=%@";
static NSString * const DOMAIN_NAME_ALL_CATEGORIES = @"https://bawl-rivne.rhcloud.com/categories/all";
static NSString * const DOMAIN_NAME_ADD_ISSUE = @"https://bawl-rivne.rhcloud.com/issue";

static NSInteger const HTTP_RESPONSE_CODE_OK = 200;
static double const MAP_REFRESHING_INTERVAL = 120.0;

@interface MapViewController () <GMSMapViewDelegate, UITabBarControllerDelegate>

@property(strong,nonatomic) NSArray *arrayOfPoints;
@property (strong, nonatomic) id <DataSorceProtocol> dataSorce;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) GMSMarker *currentMarker;
@property (assign, nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic) BOOL userLogined;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bowl";
    self.dataSorce = [[NetworkDataSorce alloc] init];
    [self checkCurrentUser];
    self.scrollViewLeadingConstraint.constant = CGRectGetWidth(self.mapView.bounds);
    self.tabBarController.delegate = self;
    [self hideTabBar];
    [self customizeTabBar];
    [self createAndShowMap];
}


-(void)checkCurrentUser
{
    
    NSDictionary *userDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"userDictionary"];
    if(userDictionary!=nil)
    {
        self.navigationItem.rightBarButtonItem.title = @"User check...";
        [self.dataSorce requestLogInWithUser:[userDictionary objectForKey:@"LOGIN"]
                                     andPass:[userDictionary objectForKey:@"PASSWORD"]
                    andViewControllerHandler:^(User *resUser)
         {
                 dispatch_async(dispatch_get_main_queue(), ^ {
                     self.currentUser = resUser;
                 });
         } andErrorHandler:^(NSError *error) {
             // error!
         }];
    }
    else
    {
        self.currentUser = nil;
        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
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
        self.title = [NSString stringWithFormat:@"Bowl"];
        self.navigationItem.rightBarButtonItem.title = @"Log In";
        self.userLogined=NO;

    }
    else
    {
        self.title = [NSString stringWithFormat:@"Bowl(%@)", user.name];
        self.navigationItem.rightBarButtonItem.title = @"Sign Out";
        self.userLogined = YES;
    }
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"fromMapToLogIn"]) 
    {
        if([segue.destinationViewController isKindOfClass:[LogInViewController class]])
        {
            LogInViewController *logInVC = (LogInViewController*)segue.destinationViewController;
            logInVC.mapDelegate = self;
            
        }
    }
    
    if([segue.identifier isEqualToString:@"fromMapToDescription"])
    {
        if([segue.destinationViewController isKindOfClass:[DescriptionViewController class]])
        {
            DescriptionViewController *DescriptionVC = (DescriptionViewController *)segue.destinationViewController;
            DescriptionVC.currentIssue = self.currentMarker.userData;
        }
    }
}


- (IBAction)sequeToLogInButton:(UIBarButtonItem *)sender {
    
    
    if (!self.userLogined)
    {
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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                                message:@"You loged out successfully! (or something like this)"
                                                               delegate:nil
                                                      cancelButtonTitle:@"I understood"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                // alert - bad
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                                message:[@"Something has gone wrong! (server answer: )" stringByAppendingString:stringAnswer]
                                                               delegate:nil
                                                      cancelButtonTitle:@"I understood"
                                                      otherButtonTitles:nil];
                [alert show];

            }
            });
        } andErrorHandler:^(NSError *error) {
            // alert - bad
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                            message:@"troubles with connection! (error in session data task obj)"
                                                           delegate:nil
                                                  cancelButtonTitle:@"I understood"
                                                  otherButtonTitles:nil];
            [alert show];

        }];
        
    }
}

#pragma mark Map
-(void)createAndShowMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:50.6283612
                                                            longitude:26.2604453
                                                                 zoom:14];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    
    [self.tabBarController.tabBar setHidden:YES];
//    [self requestIssues];
}


-(void)requestIssues
{
        [self testInternetConnection:DOMAIN_NAME_ALL_ISSUES];
        NSURL *url = [NSURL URLWithString:DOMAIN_NAME_ALL_ISSUES];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
        [[[NSURLSession sharedSession]dataTaskWithRequest:request
                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                            if (data.length > 0 && connectionError == nil){
                                        
                                                NSArray *issuesDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:0                                                                                                    error:NULL];
                                                
                                                NSMutableArray *issuesClassArray = [[NSMutableArray alloc] init];
                                                for (NSDictionary *issue in issuesDictionaryArray) {
                                                    [issuesClassArray addObject:[[Issue alloc] initWithDictionary:issue]];
                                                }
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                    [self.mapView clear];
                                                    
                                                    for (Issue *issue in issuesClassArray) {
                                                        GMSMarker *marker = [[GMSMarker alloc] init];
                                                        marker.position = CLLocationCoordinate2DMake(issue.getLatitude, issue.getLongitude);
                                                        marker.userData = issue;
                                                        marker.title = issue.name;
                                                        marker.icon = [self changeIconColor:issue];
                                                        marker.map = self.mapView;
                                                    }
                                                });
                                            } else {
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                                                                message:@"Troubles with connection!"
                                                                                               delegate:nil
                                                                                      cancelButtonTitle:@"I understood"
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
    self.currentMarker = marker;
    return NO;
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
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
    self.mapView.selectedMarker = nil;
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [self requestGoogleApiPlace:coordinate];
    [self requestCategories];
    [self addBorderColor];
    [UIView animateWithDuration:0.5 animations:^(void){
        self.scrollViewLeadingConstraint.constant = 0;
        [self hideTabBar];
        [self.view layoutIfNeeded];
    }];
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
    if ([viewController isKindOfClass:[DescriptionViewController class]]){
        DescriptionViewController *descriptionVC = (DescriptionViewController *)viewController;
        descriptionVC.currentIssue = self.currentMarker.userData;
        descriptionVC.currentUser = self.currentUser;
        descriptionVC.mapViewControllerDelegate = self;
        //descriptionVC.view.frame;
//        [descriptionVC setDataToView];
//        [descriptionVC clearOldDynamicElements];
//        [descriptionVC prepareUIChangeStatusElements];

    }
    if ([viewController isKindOfClass:[IssueHistoryViewController class]]){
        IssueHistoryViewController *issueHistoryViewController = (IssueHistoryViewController *)viewController;
        issueHistoryViewController.issue = (Issue *)self.currentMarker.userData;
    }
//    [self animateTabsSwitching:viewController];
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
    [tabBarItemLocation setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.914 green:0.31 blue:0.408 alpha:1] /*#e94f68*/ }
                                             forState:UIControlStateSelected];
    [tabBarItemDescription setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.78 green:0.784 blue:0.784 alpha:1] /*#c7c8c8*/}
                               forState:UIControlStateNormal];
    [tabBarItemDescription setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.914 green:0.31 blue:0.408 alpha:1] /*#e94f68*/}
                               forState:UIControlStateSelected];
    [tabBarItemHistory setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.78 green:0.784 blue:0.784 alpha:1] /*#c7c8c8*/}
                               forState:UIControlStateNormal];
    [tabBarItemHistory setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:0.914 green:0.31 blue:0.408 alpha:1] /*#e94f68*/ }
                               forState:UIControlStateSelected];
}

-(void)animateTabsSwitching:(UIViewController *)viewController
{
    NSUInteger controllerIndex = [self.tabBarController.viewControllers indexOfObject:viewController];
    
    UIView *fromView = self.tabBarController.selectedViewController.view;
    UIView *toView = [viewController view];
    //UIView *toView = [self.tabBarController.viewControllers[controllerIndex] view];
//    if([viewController isKindOfClass:[DescriptionViewController class]])
//    {
//        DescriptionViewController *dVC = (DescriptionViewController*)viewController;
//        [dVC setDataToView];
//    }

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

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.categoryClassArray.count;
}

// The data to return for the row and component (column) that's being passed in
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
    [self.descriptionTextView.layer setBorderColor:[[[UIColor redColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.descriptionTextView.layer setBorderWidth:1.0];
    [self.nameTextField.layer setBorderColor:[[[UIColor redColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.nameTextField.layer setBorderWidth:1.0];
    [self.categoryPicker.layer setBorderColor:[[[UIColor redColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.categoryPicker.layer setBorderWidth:1.0];
    [self.attachmentTextField.layer setBorderColor:[[[UIColor redColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.attachmentTextField.layer setBorderWidth:1.0];
}

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
    [self requestAddingNewIssue:[self getJsonFromAddingNewIssueView]];
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
                               nil];
    NSArray *addIssueKeys = [[NSArray alloc] initWithObjects:
                             @"name",
                             @"desc",
                             @"point",
                             @"status",
                             @"category",
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
                                                                           });
                                                                       }
                                                                   }];
        
        // 5
        [uploadTask resume];
    }
}

-(void)renewMap
{
    [self requestIssues];
}

-(void)renewMapWithNSTimer:(NSTimer *)timer
{
    [self requestIssues];
}

// Checks if we have an internet connection or not
- (void)testInternetConnection:(NSString *)hostName
{
    Reachability *internetReachableFoo = [Reachability reachabilityWithHostname:hostName];
    
    // Internet is reachable
//    internetReachableFoo.reachableBlock = ^(Reachability*reach)
//    {
//        // Update the UI on the main thread
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"Yayyy, we have the interwebs!");
//        });
//        reachInternet = YES;
//    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
        });
    };
    
    [internetReachableFoo startNotifier];
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

@end
