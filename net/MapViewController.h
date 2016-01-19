//
//  MapViewController.h
//  net
//
//  Created by Admin on 11.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
# import <GoogleMaps/GoogleMaps.h>
#import "User.h"

#import "IssueHistoryViewController.h"


@interface MapViewController : UIViewController <GMSMapViewDelegate>

@property(strong,nonatomic) User *currentPerson;
@property (weak, nonatomic) Issue *selectedIssue;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *descriptionButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;

@end
