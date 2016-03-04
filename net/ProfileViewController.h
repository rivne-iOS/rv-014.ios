//
//  ProfileViewController.h
//  net
//
//  Created by user on 2/10/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController <UIImagePickerControllerDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIButton *changeUserDetails;
@property (nonatomic, weak) IBOutlet UIButton *changeAvatar;

@property (nonatomic, weak) IBOutlet UITextField *userLogin;
@property (nonatomic, weak) IBOutlet UITextField *userEmail;
@property (nonatomic, weak) IBOutlet UITextField *systemRole;
@property (nonatomic, weak) IBOutlet UITextField *userName;

@property (nonatomic, weak) IBOutlet UIImageView *profileImage;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

// @property (nonatomic, weak) MapViewController *mapViewDelegate;
@property NSUInteger userID;
@property (strong, nonatomic) User *currentUser;

@end
