//
//  MapViewController.h
//  net
//
//  Created by Admin on 11.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "AFNetworking.h"
#import "YLProgressBar.h"
@import GoogleMaps;

@interface MapViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property(strong,nonatomic) User *currentUser;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *descriptionButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIView *addingIssueView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addingIssueViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *geolocationButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;

@property (weak, nonatomic) IBOutlet UILabel *tapLocationLabel;
@property (strong, nonatomic) NSMutableArray *categoryClassArray;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *attachmentTextField;
@property (weak, nonatomic) IBOutlet YLProgressBar *attachmentProgressView;
@property (weak, nonatomic) IBOutlet UILabel *attachmentSuccessfullLabel;
@property (weak, nonatomic) IBOutlet UIButton *attachmentLoadButton;

@property (weak, nonatomic) IBOutlet UIButton *geolocationButton;
@property (strong, nonatomic) GMSPlacesClient *placesClient_;


@property (strong, nonatomic) NSTimer *timerForMapRenew;



- (IBAction)buttonBackPressed:(id)sender;
- (IBAction)buttonAddPressed:(id)sender;
- (IBAction)buttonLoadPressed:(id)sender;
- (IBAction)buttonGeolocationPressed:(id)sender;
- (void)renewMapWithNSTimer:(NSTimer *)timer;
-(void)renewMap;

- (void) hideTabBar;
- (void) showTabBar;

@end
