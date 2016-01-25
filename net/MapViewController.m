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
#import "IssueHistoryViewController.h"


#import "DescriptionViewController.h"
@import GoogleMaps;

@interface MapViewController () <GMSMapViewDelegate>

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
//            DescriptionVC.mapDelegate = self;
        }
    }
    
    if ([segue.identifier isEqualToString:@"showIssueHistory"]) {
        if ([segue.destinationViewController isKindOfClass:[IssueHistoryViewController class]]) {
            IssueHistoryViewController *issueViewController = (IssueHistoryViewController*) segue.destinationViewController;
            issueViewController.issue = (Issue*)self.currentMarker.userData;
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
            
            if([stringAnswer isEqualToString:@"Your is log out"])
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
                                                                message:@"Something has gone wrong! (we have ansswer from server, but it's incorrect)"
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

-(void)createAndShowMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:50.6283612
                                                            longitude:26.2604453
                                                                 zoom:14];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    
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
                                                        marker.map = self.mapView;
                                                        marker.userData = issue;
                                                    }
                                                });
                                            }
                                        }] resume];
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [UIView animateWithDuration:0.5 animations:^(void){
        self.bottomBarConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    self.currentMarker = marker;
    return NO;
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [UIView animateWithDuration:0.5 animations:^(void){
        self.bottomBarConstraint.constant = -60;
        [self.view layoutIfNeeded];
    }];
}

@end
