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
    self.title = @"Map";
    self.userInfoText.text = @"There is no user";
    self.navigationItem.rightBarButtonItem.title = @"Log In";
    // [self updateUserInfoText];
    // Do any additional setup after loading the view.
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
}

-(void)createAndShowMap
{
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:50.6283612
                                                            longitude:26.2604453
                                                                 zoom:14];
//    GMSMapView *mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
 //   mapView_.myLocationEnabled = YES;
    self.mapView.camera = camera;
//    self.mapView = mapView_;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(50.6283612, 26.2604453);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.mapView;
//    self.mapView = mapView_;
    
    self.mapView.camera = camera;
}

-(void)requestIssues
{
        NSURL *url = [NSURL URLWithString:@"https://bawl-rivne.rhcloud.com/issues/all"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
        [[[NSURLSession sharedSession]dataTaskWithRequest:request
                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                            if (data.length > 0 && connectionError == nil)
                                            {
                                                NSArray *issuesArray = [NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:0
                                                                                                           error:NULL];
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    // Main thread
                                                });
                                            }
                                        }] resume];
}

@end
