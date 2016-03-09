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
#import "IssueCategories.h"
#import "DescriptionViewController.h"
#import "UIColor+Bawl.h"
@import MobileCoreServices;

#define TEXTFIELD_OFFSET 5
#define TEXT_LABEL_HEIGHT 21

static NSString * const GOOGLE_WEB_API_KEY = @"AIzaSyB7InJ3J2AoxlHjsYtde9BNawMINCaHykg";
static NSString * const DOMAIN_NAME_ALL_ISSUES = @"https://bawl-rivne.rhcloud.com/issue/all";
static NSString * const DOMAIN_NAME_GOOGLE_PLACE_INFO = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=%d&key=%@";
static NSString * const DOMAIN_NAME_ALL_CATEGORIES = @"https://bawl-rivne.rhcloud.com/categories/all";
static NSString * const DOMAIN_NAME_ADD_ISSUE = @"https://bawl-rivne.rhcloud.com/issue";
static NSString * const DOMAIN_NAME_ADD_ATTACHMENT = @"https://bawl-rivne.rhcloud.com/image/add/issue";

static NSInteger const HTTP_RESPONSE_CODE_OK = 200;
static double const MAP_REFRESHING_INTERVAL = 120.0;
static int const MARKER_HIDING_RADIUS = 10;

@interface MapViewController () <GMSMapViewDelegate, UITabBarControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UITextView *currentEditView;

@property (strong,nonatomic) NSArray *arrayOfPoints;
@property (strong, nonatomic) id <DataSorceProtocol> dataSorce;
@property (strong, nonatomic) GMSMarker *currentMarker;
@property (nonatomic)BOOL isMarkerSelected;
@property (assign, nonatomic) CLLocationCoordinate2D currentLocation;
@property (nonatomic) BOOL userLogined;
@property (strong, nonatomic) UIImage *attachmentImage;
@property (strong, nonatomic) NSString *attachmentFilename;
@property (strong, nonatomic) NSMutableArray *arrayOfMarkers;
@property (assign, nonatomic) BOOL isGeolocationButtonPressed;
@property (assign, nonatomic) int heightOfStatusBarInCurrentOrientation;

@property (strong, nonatomic) UIBarButtonItem *leftItem;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // even if this controller is on back, it has to listen, and perform selector!
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renewMap) name:@"renewMap" object:nil];
    
    self.isMarkerSelected = NO;
    self.heightOfStatusBarInCurrentOrientation = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.dataSorce = [[NetworkDataSorce alloc] init];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor bawlRedColor];
    
    UIFont *newFont = [UIFont fontWithName:@"ComicSansMS-Italic" size:25];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                    NSFontAttributeName : newFont};
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.leftBarButtonItem.title = @"Profile";
    self.leftItem = self.navigationItem.leftBarButtonItem;
    [self checkCurrentUser];

    self.scrollViewLeadingConstraint.constant = CGRectGetWidth(self.mapView.bounds);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.addingIssueViewHeightConstraint.constant = screenRect.size.height - self.navigationController.navigationBar.frame.size.height - self.heightOfStatusBarInCurrentOrientation;
    
    self.tabBarController.delegate = self;
    self.descriptionTextView.delegate = self;
    [self hideTabBar];
    [self customizeTabBar];
    [self customizeGeolocationButton];
    [self createAndShowMap];
    [self addBorderColor];
    [self customiseProgressBarView];
    [IssueCategories earlyPreparing];
    [self requestCategories];
    
}

-(void)addKeyboardObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)removeKeyboardObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void)keyboardDidShow:(NSNotification*)notification
{
    CGFloat bottomCurrentFieldByScrollView;
    NSDictionary *dic = notification.userInfo;
    NSValue *keyboardFrame = dic[UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [keyboardFrame CGRectValue];
    CGRect viewFrame = [self.view convertRect:frame fromView:nil];
    CGFloat keyboardHeight = viewFrame.size.height;
    
    self.scrollViewBottomConstraint.constant = keyboardHeight;
    [self.view layoutIfNeeded];
    
    if (self.currentEditView == nil)
        return;
    
    CGRect visibleRect = [self.scrollView convertRect:self.scrollView.bounds toView:self.addingIssueView];
    
    if (visibleRect.size.height < self.descriptionTextView.frame.size.height)
        bottomCurrentFieldByScrollView = self.currentEditView.frame.origin.y - visibleRect.origin.y + visibleRect.size.height - TEXTFIELD_OFFSET - TEXT_LABEL_HEIGHT;
    else
        bottomCurrentFieldByScrollView = self.currentEditView.frame.origin.y - visibleRect.origin.y + self.currentEditView.bounds.size.height + TEXTFIELD_OFFSET;
    CGFloat bottomScrollView = self.scrollView.bounds.size.height;
    
    if(bottomCurrentFieldByScrollView != bottomScrollView)
    {
        CGFloat yMove = bottomCurrentFieldByScrollView - bottomScrollView;
        CGFloat newY = (visibleRect.origin.y + yMove < 0) ? 0 : visibleRect.origin.y + yMove;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollView.contentOffset = CGPointMake(visibleRect.origin.x, newY);
        }];
        
    }
    
}

-(void)keyboardWillHide
{
    self.scrollViewBottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    self.currentEditView = textView;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.currentEditView = nil;
}

-(void)checkCurrentUser
{
    
    NSDictionary *userDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"userDictionary"];
    if(userDictionary!=nil)
    {
        self.navigationItem.rightBarButtonItem.title = @"Log in...";
        [self.dataSorce requestLogInWithUser:[userDictionary objectForKey:@"LOGIN"]
                                     andPass:[userDictionary objectForKey:@"PASSWORD"]
                    andViewControllerHandler:^(User *resUser, NSError *error)
         {
                 dispatch_async(dispatch_get_main_queue(), ^ {
                     self.currentUser = resUser;
                     [CurrentItems sharedItems].user = resUser;
                 });
         }];
    }
    else
    {
        self.currentUser = nil; // sharedItems.user is already nil;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self addKeyboardObserver];
    [self.geolocationButton setHidden:NO];
    
    if(self.currentUser==nil)
    {
        self.currentUser = [CurrentItems sharedItems].user;
    }
    
    [self renewMap];
    
    [self.timerForMapRenew invalidate];

    self.timerForMapRenew = [NSTimer scheduledTimerWithTimeInterval:MAP_REFRESHING_INTERVAL
                                     target:self
                                   selector:@selector(renewMapWithNSTimer:)
                                   userInfo:nil
                                    repeats:YES];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:self.timerForMapRenew forMode: NSDefaultRunLoopMode];
    
    if ([CurrentItems sharedItems].user)
        self.navigationItem.leftBarButtonItem = self.leftItem;
    else self.navigationItem.leftBarButtonItem = nil;
}

-(void)selectCurrentMarker
{
        if(self.isMarkerSelected == YES) {
            self.tabBarController.tabBar.hidden = NO;
            CurrentItems *cItems = [CurrentItems sharedItems];
            for (GMSMarker *marker in self.arrayOfMarkers){
                if ([cItems.issue.issueId intValue] == [((Issue *)marker.userData).issueId intValue]){
                    self.mapView.selectedMarker = nil;
                    [self.mapView setSelectedMarker:nil];
                    self.mapView.selectedMarker = marker;
                    [self.mapView setSelectedMarker:marker];
                    break;
                }
            }
        }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self removeKeyboardObserver];
    [self.timerForMapRenew invalidate];
}

-(void)setCurrentUser:(User *) user
{
    _currentUser = user;
    if(user == nil)
    {
        self.navigationItem.rightBarButtonItem.title = @"Log In";
        self.navigationItem.leftBarButtonItem = nil;
        self.userLogined=NO;

    }
    else
    {
        [self.tabBarController.tabBar.items objectAtIndex:0].title = @"Location";
        self.navigationItem.rightBarButtonItem.title = @"Log Out";
        self.navigationItem.leftBarButtonItem = self.leftItem;
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
        sender.tintColor = [sender.tintColor colorWithAlphaComponent:0.3];
        sender.enabled = NO;
        
        [self.dataSorce requestSignOutWithHandler:^(NSString *stringAnswer, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{

            if([stringAnswer isEqualToString:[@"Bye " stringByAppendingString:self.currentUser.name]])
            {
                // alert - good
                self.navigationItem.rightBarButtonItem.title = @"Log In";
                self.navigationItem.leftBarButtonItem = nil;
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
            [CurrentItems sharedItems].user = nil;
            self.currentUser = nil;
            sender.tintColor = [sender.tintColor colorWithAlphaComponent:1];
            sender.enabled = YES;
                

            });
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
                                                    [self.arrayOfMarkers removeAllObjects];
                                                    
                                                    self.arrayOfMarkers = [[NSMutableArray alloc] init];
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
                                                            
                                                            [self.arrayOfMarkers addObject:marker];
                                                        }
                                                    }
                                                    [self optimizeUIByHidingMarkers];
                                                    [self selectCurrentMarker];
                                                });
                                            } else {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                                                                    message:@"Troubles with connection!"
                                                                                                   delegate:nil
                                                                                          cancelButtonTitle:@"OK"
                                                                                          otherButtonTitles:nil];
                                                    [alert show];
                                                });
                                            }
                                        }] resume];
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [self.tabBarController.tabBar setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^(void){
        [self showTabBar];
        [self changeGeolocationButtonPosition:63.0];
        [self.view layoutIfNeeded];
    }];
    self.isMarkerSelected = YES;
    
    CurrentItems *cItems = [CurrentItems sharedItems];
    cItems.issueImage = nil;
    cItems.issue = marker.userData;
    
    return NO;
}

-(void)liftUpGeolocationButton
{
    self.geolocationButtonBottomConstraint.constant = 48 + 15;
}

-(void)pullDownGeolocationButton
{
    self.geolocationButtonBottomConstraint.constant = 15;
}

-(void)changeGeolocationButtonPosition:(double)bottomConstant
{
    self.geolocationButtonBottomConstraint.constant = bottomConstant;
}

-(void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    [self revealAllMarkers];
    [self optimizeUIByHidingMarkers];
}

-(void)revealAllMarkers
{
    for (GMSMarker *marker in self.arrayOfMarkers){
        marker.map = self.mapView;
    }
}

-(void)hideAllMarkers
{
    for (GMSMarker *marker in self.arrayOfMarkers){
        marker.map = nil;
    }
}

-(void)optimizeUIByHidingMarkers
{
    CurrentItems *cItems = [CurrentItems sharedItems];
    
    //(x-x0)^2 + (y-y0)^2 = R^2
    for (GMSMarker *markerFirst in self.arrayOfMarkers){
        for (GMSMarker *markerSecond in self.arrayOfMarkers){
            CGPoint pixelPointFirstMarker = [self.mapView.projection pointForCoordinate:markerFirst.position];
            CGPoint pixelPointSecondMarker = [self.mapView.projection pointForCoordinate:markerSecond.position];
            
            if (markerFirst != markerSecond && markerFirst.map != nil && markerSecond.map != nil && pixelPointFirstMarker.x >= 0 && pixelPointFirstMarker.y >= 0 && pixelPointSecondMarker.x >=0 && pixelPointSecondMarker.y >=0){
                if (pow((pixelPointSecondMarker.x - pixelPointFirstMarker.x), 2.0) + pow((pixelPointSecondMarker.y - pixelPointFirstMarker.y), 2.0) <= pow(MARKER_HIDING_RADIUS, 2.0)){
                    if (cItems.issue.issueId == ((Issue *)markerSecond.userData).issueId)
                        self.tabBarController.tabBar.hidden = YES;
                    markerSecond.map = nil;
                }
            }
        }
    }
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.isMarkerSelected = NO;
    [UIView animateWithDuration:0.5 animations:^(void){
        [self hideTabBar];
        [self changeGeolocationButtonPosition:15.0];
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
        
        [self.tabBarController.tabBar setHidden:YES];
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.5 animations:^(void){
            self.scrollViewLeadingConstraint.constant = 0;
            [self changeGeolocationButtonPosition:15.0];
            [self hideTabBar];
            [self.view layoutIfNeeded];
        }];
        [self.geolocationButton setHidden:YES];
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
                                                [self retrievePlaceInfoByPlaceId:[self takePlaceIdFromGoogleApiPlace:data] andData:data];
                                                });
                                        }
                                    }] resume];

}

-(NSString *)takePlaceIdFromGoogleApiPlace:(NSData *)data
{
    NSDictionary *placeDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSArray *resultsArray = [placeDictionary valueForKey:@"results"];
    NSDictionary *locationDictionary = [resultsArray objectAtIndex:0];
    NSString *placeId = [locationDictionary valueForKey:@"place_id"];
    return placeId;
    
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
    if ([viewController isKindOfClass:[UINavigationController class]] && [viewController.restorationIdentifier isEqualToString:@"history"]){
        UINavigationController *destController = (UINavigationController *)viewController;
        [destController popToRootViewControllerAnimated:NO];
        IssueHistoryViewController *issueHistoryViewController = (IssueHistoryViewController *)destController.topViewController;
//        issueHistoryViewController.title = self.title;
//        issueHistoryViewController.isLogged = self.userLogined;
//        issueHistoryViewController.dataSorce = self.dataSorce;
        issueHistoryViewController.mapDelegate = self;
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
    } completion:^(BOOL finished){
        if (finished == YES)
            [self.geolocationButton setHidden:NO];
    }];
}

- (IBAction)buttonAddPressed:(id)sender
{
    if (![self checkFields]){
        [self showAlert:@"Validation error" withMessage:@"Fill all fields!"];
        return;
    }
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
                               [NSNumber numberWithLong:[self.categoryPicker selectedRowInComponent:0]],
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
    NSLog(@"renew Map");
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
    if (size.width > size.height)
        self.heightOfStatusBarInCurrentOrientation = 0;
    else
        self.heightOfStatusBarInCurrentOrientation = [UIApplication sharedApplication].statusBarFrame.size.height;
    
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

-(void)retrievePlaceInfoByPlaceId:(NSString *)placeId andData:(NSData *)data
{
    GMSPlacesClient *placesClient = [GMSPlacesClient sharedClient];
    [placesClient lookUpPlaceID:placeId callback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Place Details error %@", [error localizedDescription]);
            return;
        }
        
        if (place != nil) {
            NSString *regionName;
            NSString *streetName;
            NSString *placeAddressString = place.formattedAddress;
            NSArray *placeAddressArray = [placeAddressString componentsSeparatedByString:@","];

            if ([placeAddressArray[1] rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound){
                regionName = placeAddressArray[1];
                streetName = placeAddressArray[0];
            } else {
                regionName = placeAddressArray[2];
                streetName = placeAddressArray[0];
            }
            
            self.tapLocationLabel.numberOfLines = 5;
            self.tapLocationLabel.lineBreakMode = NSLineBreakByWordWrapping;
            self.tapLocationLabel.text = @"";
            if (![streetName isEqual:@"Unnamed Road"])
                self.tapLocationLabel.text = [self.tapLocationLabel.text stringByAppendingFormat:@"Location of issue:\n%@, %@", regionName, streetName];
            else
                self.tapLocationLabel.text = [self.tapLocationLabel.text stringByAppendingFormat:@"Location of issue:\n%@", regionName];
            [self fixDescriptionTextViewHeight];
        } else {
            NSLog(@"No place details for %@", placeId);
        }
    }];
}

-(void)fixDescriptionTextViewHeight
{
    [self.view layoutIfNeeded];
    [self.addingIssueView addConstraint:[NSLayoutConstraint constraintWithItem:self.descriptionTextView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:self.descriptionTextView.frame.size.height]];
    
    [self.addingIssueView removeConstraint:self.buttonAddBottomConstraint];
    [self.view layoutIfNeeded];
}

-(void)customizeGeolocationButton
{
    self.geolocationButton.layer.cornerRadius = self.geolocationButton.bounds.size.width / 2.0;
    self.geolocationButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.geolocationButton.layer.shadowOpacity = 0.7;
    self.geolocationButton.layer.shadowRadius = 6;
    self.geolocationButton.layer.shadowOffset = CGSizeMake(6.0f, 6.0f);
}

-(IBAction)buttonGeolocationPressed:(id)sender
{
    self.isMarkerSelected = NO;
    self.mapView.selectedMarker = nil;
    [self hideTabBar];
    [self changeGeolocationButtonPosition:15.0];
    [self.tabBarController.tabBar setHidden:YES];
    [self.view layoutIfNeeded];
    
    self.placesClient_ = [GMSPlacesClient sharedClient];
    [self.placesClient_ currentPlaceWithCallback:^(GMSPlaceLikelihoodList *likelihoodList, NSError *error) {
        if (error != nil) {
            NSLog(@"Current Place error %@", [error localizedDescription]);
            return;
        }
        
        // First element because it has the highest accuracy of user place detection.
        GMSPlaceLikelihood *likelyhood = likelihoodList.likelihoods[0];
        GMSPlace *place = likelyhood.place;
        [self showClosestMarkersToGeolocation:place.coordinate];
    }];
}

-(double)arcDistance:(CLLocationCoordinate2D)loc1 andSecondPoint:(CLLocationCoordinate2D)loc2 {
    double rad  = M_PI / 180.0,
    earth_radius = 6371.009, // close enough
    lat1 = loc1.latitude * rad,
    lat2 = loc2.latitude * rad,
    dlon = fabs(loc1.longitude - loc2.longitude) * rad;
    
    return earth_radius * acos((sin(lat1) * sin(lat2)) + (cos(lat1) * cos(lat2) * cos(dlon)));
}

-(void)showClosestMarkersToGeolocation:(CLLocationCoordinate2D)geolocation
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [self.mapView moveCamera:[GMSCameraUpdate zoomTo:[GMSCameraPosition zoomAtCoordinate:geolocation forMeters:5000.0 perPoints:screenRect.size.width]]];
    [self.mapView animateToLocation:geolocation];
}

-(int)calculateZoomLevel:(int)screenWidth
{
    double equatorLength = 40075004.0; // in meters
    double widthInPixels = screenWidth;
    double metersPerPixel = equatorLength / 256.0;
    int zoomLevel = 1;
    while ((metersPerPixel * widthInPixels) > 10000) {
        metersPerPixel /= 2;
        ++zoomLevel;
    }
    NSLog(@"Zoom level is %d", zoomLevel);
    return zoomLevel;
}

double getDistanceMetresBetweenLocationCoordinates(CLLocationCoordinate2D coord1,
                                                   CLLocationCoordinate2D coord2)
{
    CLLocation* location1 =
    [[CLLocation alloc]
     initWithLatitude: coord1.latitude
     longitude: coord1.longitude];
    CLLocation* location2 =
    [[CLLocation alloc]
     initWithLatitude: coord2.latitude
     longitude: coord2.longitude];
    
    return [location1 distanceFromLocation: location2];
}

@end
