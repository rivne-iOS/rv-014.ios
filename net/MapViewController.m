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

#import "DescriptionViewController.h"
@import GoogleMaps;

@interface MapViewController () <GMSMapViewDelegate, UITabBarControllerDelegate>

@property(strong,nonatomic) NSArray *arrayOfPoints;
@property (strong, nonatomic) id <DataSorceProtocol> dataSorce;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) GMSMarker *currentMarker;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bowl";
    self.dataSorce = [[NetworkDataSorce alloc] init];
    self.navigationItem.rightBarButtonItem.title = @"Log In";
    
    self.tabBarController.delegate = self;
    [self hideTabBar];
    [self customizeTabBar];
    [self createAndShowMap];
}

-(void)setCurrentUser:(User *) user
{
    _currentUser = user;
    if(user == nil)
    {
        self.title = [NSString stringWithFormat:@"Bowl"];
        self.navigationItem.rightBarButtonItem.title = @"Log In";

    }
    else
    {
        self.title = [NSString stringWithFormat:@"Bowl(%@)", user.name];
        self.navigationItem.rightBarButtonItem.title = @"Sing Out";
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
    
    
    if ([sender.title isEqualToString:@"Log In"])
    {
        [self performSegueWithIdentifier:@"fromMapToLogIn" sender:self];
    }
    else if ([sender.title isEqualToString:@"Sing Out"])
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
    [self requestIssues];
}


-(void)requestIssues
{
        NSURL *url = [NSURL URLWithString:@"https://bawl-rivne.rhcloud.com/issue/all"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
        [[[NSURLSession sharedSession]dataTaskWithRequest:request
                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                            if (data.length > 0 && connectionError == nil)
                                            {
                                        
                                                NSArray *issuesDictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:0                                                                                                    error:NULL];
                                                
                                                NSMutableArray *issuesClassArray = [[NSMutableArray alloc] init];
                                                for (NSDictionary *issue in issuesDictionaryArray) {
                                                    [issuesClassArray addObject:[[Issue alloc] initWithDictionary:issue]];
                                                }
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    for (Issue *issue in issuesClassArray) {
                                                        GMSMarker *marker = [[GMSMarker alloc] init];
                                                        marker.position = CLLocationCoordinate2DMake(issue.getLatitude, issue.getLongitude);
                                                        marker.userData = issue;
                                                        marker.title = issue.name;
                                                        marker.map = self.mapView;
                                                    }
                                                });
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
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[DescriptionViewController class]]){
        DescriptionViewController *descriptionVC = (DescriptionViewController *)viewController;
        descriptionVC.currentIssue = self.currentMarker.userData;
        descriptionVC.currentMarker = self.currentMarker;
        descriptionVC.currentUser = self.currentUser;
        //descriptionVC.view.frame;
//        [descriptionVC setDataToView];
//        [descriptionVC clearOldDynamicElements];
//        [descriptionVC prepareUIChangeStatusElements];

    }
    //[self animateTabsSwitching:viewController];
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
@end
