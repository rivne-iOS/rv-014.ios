//
//  MapViewController.h
//  net
//
//  Created by Admin on 11.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

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

@property (weak, nonatomic) IBOutlet UILabel *tapLocationLabel;
@property (strong, nonatomic) NSMutableArray *categoryClassArray;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;

@end
