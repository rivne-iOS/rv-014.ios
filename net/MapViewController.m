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
@import GoogleMaps;

@interface MapViewController ()

@property(strong,nonatomic) NSArray *arrayOfPoints;
@property (weak, nonatomic) IBOutlet UITextView *userInfoText;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.title = @"Map";
    self.userInfoText.text = @"There is no user";
    self.navigationItem.rightBarButtonItem.title = @"Log In";
    // [self updateUserInfoText];
    // Do any additional setup after loading the view.
    [self setButtonImages];
    [self createAndShowMap];
}



-(void)setCurrentPerson:(User *) person
{
    _currentPerson = person;
    if(person == nil)
    {
        self.userInfoText.text = @"There is no user";
        self.navigationItem.rightBarButtonItem.title = @"Log In";

    }
    else
    {
        self.userInfoText.text = [person description];
        self.navigationItem.rightBarButtonItem.title = @"Sing Out";
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if ([segue.identifier isEqualToString:@"showIssueHistory"]) {
        if ([segue.destinationViewController isKindOfClass:[IssueHistoryViewController class]]) {
            IssueHistoryViewController *issueViewController = (IssueHistoryViewController*) segue.destinationViewController;
            issueViewController.issue = self.selectedIssue;
        }
    }
}

-(void)createAndShowMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:50.6283612
                                                            longitude:26.2604453
                                                                 zoom:14];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    
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
                                                NSArray *issuesDictionaryArray = [NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:0
                                                                                                           error:NULL];
                                                
                                                NSMutableArray *issuesClassArray = [[NSMutableArray alloc] init];
                                                for (NSDictionary *issue in issuesDictionaryArray) {
                                                    [issuesClassArray addObject:[[Issue alloc] initWithDictionary:issue]];
                                                }
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    for (Issue *issue in issuesClassArray) {
                                                        GMSMarker *marker = [[GMSMarker alloc] init];
                                                        marker.position = CLLocationCoordinate2DMake(issue.getLatitude, issue.getLongitude);
                                                        marker.map = self.mapView;
                                                        marker.userData = issue;
                                                    }
                                                });
                                            }
                                        }] resume];
}

-(void)setButtonImages
{
    [_locationButton setImage:[UIImage imageNamed:@"location_enabled.png"] forState:UIControlStateNormal];
    [_descriptionButton setImage:[UIImage imageNamed:@"description_disabled.png"] forState:UIControlStateNormal];
    [_historyButton setImage:[UIImage imageNamed:@"history_disabled.png"] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage imageNamed:@"more.png"] forState:UIControlStateNormal];
}

- (BOOL) mapView:(GMSMapView *) mapView didTapMarker:(GMSMarker *) 	marker {
    self.selectedIssue = (Issue*)marker.userData;
    
    return true;
}
@end
