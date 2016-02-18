//
//  ProfileViewController.m
//  net
//
//  Created by user on 2/10/16.
//  Copyright © 2016 Admin. All rights reserved.
//
#import "MapViewController.h"
#import "ProfileViewController.h"
#import "LogInViewController.h"
#import "DataSorceProtocol.h"
#import "UIColor+Bawl.h"
#import "User.h"
#import "CurrentItems.h"
#import "UIView+Addition.h"

static NSString const * const AVATAR_NO_IMAGE = @"no_avatar.png";

@interface ProfileViewController ()

@property (nonatomic, weak) IBOutlet UILabel *labelUserLogin;
@property (nonatomic, weak) IBOutlet UILabel *labelSystemRole;
@property (nonatomic, weak) IBOutlet UILabel *labelUserEmail;

@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString *avatarImageURL;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.changeUserDetails setBackgroundColor:[UIColor bawlRedColor]];
    [self.changeAvatar setBackgroundColor:[UIColor bawlRedColor]];
    
    [self hideAllViews];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self hideAllViews];
    
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
    
    if ([CurrentItems sharedItems].user) {
        self.navigationItem.rightBarButtonItem.title = @"Log Out";
    }
    else {
        self.navigationItem.rightBarButtonItem.title = @"Log In";
    }
    
    if ([CurrentItems sharedItems].user && (self.userID == [CurrentItems sharedItems].user.userId)) {
        self.profileImage.image = [CurrentItems sharedItems].userImage;
        
        [self.userLogin setText:[NSString stringWithFormat:@"@%@", [CurrentItems sharedItems].user.login]];
        [self.userEmail setText:[CurrentItems sharedItems].user.email];
        [self.userName setText:[CurrentItems sharedItems].user.name];
        
        switch ([CurrentItems sharedItems].user.role) {
            case ADMIN:
                [self.systemRole setText:@"ADMIN"];
                break;
            case MANAGER:
                [self.systemRole setText:@"MANAGER"];
                break;
            case USER:
                [self.systemRole setText:@"USER"];
                break;
            case SUBSCRIBER:
                [self.systemRole setText:@"SUBSCRIBER"];
                break;
        }
        [self revealAllViews];
    }
    else {
        [self requestUserDetailsByID:self.userID updateScreenWithHandler:^(User *user){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.userLogin setText:[NSString stringWithFormat:@"@%@", user.login]];
                [self.userEmail setText:user.email];
                [self.userName setText:user.name];
                
                switch (user.role) {
                    case ADMIN:
                        [self.systemRole setText:@"ADMIN"];
                        break;
                    case MANAGER:
                        [self.systemRole setText:@"MANAGER"];
                        break;
                    case USER:
                        [self.systemRole setText:@"USER"];
                        break;
                    case SUBSCRIBER:
                        [self.systemRole setText:@"SUBSCRIBER"];
                        break;
                }
                if (self.avatarImageURL)
                    [self requestAvatarWithName:self.avatarImageURL];
                else [self requestAvatarWithName:AVATAR_NO_IMAGE];
            });
        }];

    }
    
    [self.mapViewDelegate hideTabBar];
    self.tabBarController.tabBar.hidden = YES;
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2.0f;
    self.profileImage.clipsToBounds = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) hideAllViews {
    [self.profileImage setHidden:YES];
    [self.userName setHidden:YES];
    [self.labelUserLogin setHidden:YES];
    [self.userLogin setHidden:YES];
    [self.labelUserEmail setHidden:YES];
    [self.userEmail setHidden:YES];
    [self.labelSystemRole setHidden:YES];
    [self.systemRole setHidden:YES];
    [self.changeUserDetails setHidden:YES];
    [self.changeAvatar setHidden:YES];
}

- (void) revealAllViews {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.profileImage setHidden:NO];
        [self.userName setHidden:NO];
        [self.labelUserLogin setHidden:NO];
        [self.userLogin setHidden:NO];
        [self.labelUserEmail setHidden:NO];
        [self.userEmail setHidden:NO];
        [self.labelSystemRole setHidden:NO];
        [self.systemRole setHidden:NO];
        
        if (self.userID == [CurrentItems sharedItems].user.userId) {
            [self.changeUserDetails setHidden:NO];
            [self.changeAvatar setHidden:NO];
        }
        
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
    });
}

- (void) requestAvatarWithName: (NSString *) avatarName {
    NSString *urlString = [NSString stringWithFormat:@"https://bawl-rivne.rhcloud.com/image/%@", avatarName];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *requset = [NSURLRequest requestWithURL:url];
    
    [[[NSURLSession sharedSession]   dataTaskWithRequest:requset
                                      completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError){
                                          if (data.length > 0 && connectionError == nil) {
                                              UIImage *tmpImage = [[UIImage alloc] initWithData:data];
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  self.profileImage.image = tmpImage;
                                                  [self revealAllViews];
                                              });
                                              
                                          }
                                          
    }] resume];
}

- (void) requestUserDetailsByID: (NSUInteger) ID updateScreenWithHandler:(void(^)(User *)) handler {
    NSString *urlString = [NSString stringWithFormat:@"https://bawl-rivne.rhcloud.com/users/%li",(unsigned long)self.userID];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [[[NSURLSession sharedSession]dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                        if (data.length > 0 && connectionError == nil)
                                        {
                                            NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:0
                                                                                                       error:NULL];
                                            self.avatarImageURL = [NSString stringWithFormat:@"%@", userData[@"AVATAR"]];
                                            User *user = [[User alloc] initWitDictionary:userData];
                                            
                                            handler(user);
                                        }
                                    }] resume];
}

- (IBAction)sequeToLogInButton:(UIBarButtonItem *)sender {
    
    
    if (!self.isLogged)
    {
        [self performSegueWithIdentifier:@"fromProfileToLogIn" sender:self];
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
            });
        } andErrorHandler:^(NSError *error) {
            // alert - bad
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log Out"
                                                            message:@"Problem with internet connection"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }];
        
    }
}

- (void) sendProfileImage: (UIImage *)profileImage {
    NSString *urlString = [NSString stringWithFormat:@"https://bawl-rivne.rhcloud.com/image"];
    NSData *imageData = UIImagePNGRepresentation(profileImage);
    NSString *postLength = [NSString stringWithFormat:@"%d", [imageData length]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL:url];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:imageData];
    
    [[[NSURLSession sharedSession]dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                        if (data.length > 0 && connectionError == nil)
                                        {
                                            //to do: set avatar name to user
                                        }
                                    }] resume];

}

#pragma mark - Change Avatar
- (IBAction)changeAvatar:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *pickedImage = info[UIImagePickerControllerEditedImage];
    
    [self sendProfileImage:pickedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Change User Datails

- (IBAction)changeUserDatails:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"Change User Details"]) {
        [self.changeUserDetails setTitle:@"Save" forState:UIControlStateNormal];
        [self.userLogin setEnabled:YES];
        [self.userName setEnabled:YES];
        [self.userEmail setEnabled:YES];
        
        [self.userName setBorderStyle:UITextBorderStyleRoundedRect];
        [self.userLogin setBorderStyle:UITextBorderStyleRoundedRect];
        [self.userEmail setBorderStyle:UITextBorderStyleRoundedRect];
        
        [self.userName setBorderForColor:[UIColor bawlRedColor03alpha] width:0.5f radius:1.0f];
        [self.userLogin setBorderForColor:[UIColor bawlRedColor03alpha] width:0.5f radius:1.0f];
        [self.userEmail setBorderForColor:[UIColor bawlRedColor03alpha] width:0.5f radius:1.0f];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Save"]) {
        [self.changeUserDetails setTitle:@"Change User Details" forState:UIControlStateNormal];
        [self.userLogin setEnabled:NO];
        [self.userName setEnabled:NO];
        [self.userEmail setEnabled:NO];
        
        [self.userName setBorderStyle:UITextBorderStyleNone];
        [self.userLogin setBorderStyle:UITextBorderStyleNone];
        [self.userEmail setBorderStyle:UITextBorderStyleNone];
        
        [self.userName setBorderForColor:nil width:0.0f radius:0.0f];
        [self.userLogin setBorderForColor:nil width:0.0f radius:0.0f];
        [self.userEmail setBorderForColor:nil width:0.0f radius:0.0f];
        // to do send request for change user datails
    }
}

@end
