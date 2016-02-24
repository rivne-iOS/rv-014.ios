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
#import "UIViewController+backViewController.h"
#import "IssueHistoryViewController.h"
#import "NSString+stringIsEmpry.h"
#import "User.h"

static NSString const * const AVATAR_NO_IMAGE = @"no_avatar.png";
static NSString const * const DOMAIN_CHANGE_USER_DETAILS = @"https://bawl-rivne.rhcloud.com/users/";
static NSInteger const HTTP_RESPONSE_CODE_OK = 200;

@interface ProfileViewController ()

@property (nonatomic, weak) IBOutlet UILabel *labelUserLogin;
@property (nonatomic, weak) IBOutlet UILabel *labelSystemRole;
@property (nonatomic, weak) IBOutlet UILabel *labelUserEmail;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;

@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString *avatarImageURL;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.changeUserDetails setBackgroundColor:[UIColor bawlRedColor]];
    [self.changeAvatar setBackgroundColor:[UIColor bawlRedColor]];
    
    [self.progressView setAlpha:0.0];
    
    [self hideAllViews];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
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
    
    if ([[self backViewController] isKindOfClass:[IssueHistoryViewController class]]) {
    
        if ([CurrentItems sharedItems].user && (self.userID == [CurrentItems sharedItems].user.userId)) {
            [self setUserProfileDetails:[CurrentItems sharedItems].user isLoggedUser:YES];
        }
        else {
            [self requestUserDetailsByID:self.userID updateScreenWithHandler:^(User *user){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setUserProfileDetails:user isLoggedUser:NO];
                    
                    if (![NSString stringIsEmpty:self.avatarImageURL])
                        [self requestAvatarWithName:self.avatarImageURL];
                    else [self requestAvatarWithName:AVATAR_NO_IMAGE];
                });
            }];
            
        }
    }
    else {
        [self setUserProfileDetails:[CurrentItems sharedItems].user isLoggedUser:YES];
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

- (void) setUserProfileDetails: (User *)user isLoggedUser:(BOOL) isLoggedUser{
    
    if (isLoggedUser) self.profileImage.image = [CurrentItems sharedItems].userImage;
    
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
    [self revealAllViews];
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
        
        if ([[self backViewController] isKindOfClass:[IssueHistoryViewController class]]) {
            if (self.userID == [CurrentItems sharedItems].user.userId) {
                [self.changeUserDetails setHidden:NO];
                [self.changeAvatar setHidden:NO];
            }
        }
        else {
            [self.changeUserDetails setHidden:NO];
            [self.changeAvatar setHidden:NO];
        }
        
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
    });
}

- (void) requestAvatarWithName: (NSString const * const) avatarName {
    NSString *urlString = [NSString stringWithFormat:@"https://bawl-rivne.rhcloud.com/image/%@", avatarName];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *requset = [NSURLRequest requestWithURL:url];
    
    __weak ProfileViewController *weakSelf = self;
    
    [[[NSURLSession sharedSession]   dataTaskWithRequest:requset
                                      completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError){
                                          if (data.length > 0 && connectionError == nil) {
                                              UIImage *tmpImage = [[UIImage alloc] initWithData:data];
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  weakSelf.profileImage.image = tmpImage;
                                                  [weakSelf revealAllViews];
                                              });
                                              
                                          }
                                          
    }] resume];
}

- (void) requestUserDetailsByID: (NSUInteger) ID updateScreenWithHandler:(void(^)(User *)) handler {
    NSString *urlString = [NSString stringWithFormat:@"https://bawl-rivne.rhcloud.com/users/%li",(unsigned long)self.userID];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __weak ProfileViewController *selfWeak = self;
    
    [[[NSURLSession sharedSession]dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                        if (data.length > 0 && connectionError == nil)
                                        {
                                            NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:0
                                                                                                       error:NULL];
                                            if (![userData[@"AVATAR"] isKindOfClass:[NSNull class]])
                                                selfWeak.avatarImageURL = [[NSString alloc] initWithString:userData[@"AVATAR"]];
                                            else selfWeak.avatarImageURL = nil;
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
    NSString *urlString = [NSString stringWithFormat:@"https://bawl-rivne.rhcloud.com/image/add/avatar"];
    NSData *imageData = UIImageJPEGRepresentation(profileImage, 1.0);
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"avatar_picture.jpg" mimeType:@"image/jpeg"];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    __weak ProfileViewController *weakSelf = self;
    
    [UIView animateWithDuration:1.0 animations:^(void) {
        [weakSelf.progressView setAlpha:1.0];
    }];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          [weakSelf.progressView setProgress:uploadProgress.fractionCompleted animated:YES];
                          if (uploadProgress.fractionCompleted == 1.0) {
                              [UIView animateWithDuration:1.0 animations:^(void) {
                                  [weakSelf.progressView  setAlpha:0.0];
                              }];
                          }
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      
                      if (error) {
                          [UIView animateWithDuration:1.0 animations:^(void) {
                              [weakSelf.progressView  setAlpha:0.0];
                          }];
                          NSLog(@"Error: %@", error);
                      } else {
                          NSLog(@"%@ %@", response, responseObject);
                          NSArray *value = [[NSArray alloc] initWithObjects:responseObject[@"filename"], nil];
                          NSArray *key = [[NSArray alloc] initWithObjects:@"avatar", nil];
                          NSDictionary *JSONdic = [[NSDictionary alloc] initWithObjects:value forKeys:key];
                          
                          [weakSelf requestChangeUserDetails:JSONdic completionHandler:^(void){
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [CurrentItems sharedItems].userImage = profileImage;
                                  [weakSelf.profileImage setImage:profileImage];
                              });
                          }];
                      }
                  }];
    
    [uploadTask resume];
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

#pragma mark - request Change User Details

- (NSDictionary *) getJSONfromChangeUserDetails {
    NSArray *values = [[NSArray alloc] initWithObjects:self.userName.text
                                                    ,self.userEmail.text
                                                    ,nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"name",
                                                     @"email",
                                                     nil];
    NSDictionary *JSONdic = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    
    return JSONdic;
}

- (void) requestChangeUserDetails: (NSDictionary *) jsonDictionary  completionHandler:(void(^)(void)) handler {
    NSString *strUrl = [NSString stringWithFormat:@"%@%li",DOMAIN_CHANGE_USER_DETAILS, (unsigned long)[CurrentItems sharedItems].user.userId];
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                   options:kNilOptions error:&error];
    
    if (!error) {
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                   fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                       NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                                       if ([httpResponse statusCode] != HTTP_RESPONSE_CODE_OK) {
                                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                                                                                           message:@"Something has gone wrong! (we have ansswer from server, but it's incorrect)"
                                                                                                                          delegate:nil
                                                                                                                 cancelButtonTitle:@"I understood"
                                                                                                                 otherButtonTitles:nil];
                                                                           [alert show];
                                                                       }
                                                                       else if (handler)
                                                                           handler();
                                                                   }];
        [uploadTask resume];
    }
}

#pragma mark - Change User Datails

- (IBAction)changeUserDatails:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"Change User Details"]) {
        [self.changeUserDetails setTitle:@"Save" forState:UIControlStateNormal];
        [self.userLogin setEnabled:YES];
        [self.userName setEnabled:YES];
        [self.userEmail setEnabled:YES];
        
        [self.userName setBorderForColor:[UIColor bawlRedColor03alpha] width:0.5f radius:5.0f];
        [self.userLogin setBorderForColor:[UIColor bawlRedColor03alpha] width:0.5f radius:5.0f];
        [self.userEmail setBorderForColor:[UIColor bawlRedColor03alpha] width:0.5f radius:5.0f];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Save"]) {
        [self.changeUserDetails setTitle:@"Change User Details" forState:UIControlStateNormal];
        [self.userLogin setEnabled:NO];
        [self.userName setEnabled:NO];
        [self.userEmail setEnabled:NO];
        
        [self.userName setBorderForColor:nil width:0.0f radius:0.0f];
        [self.userLogin setBorderForColor:nil width:0.0f radius:0.0f];
        [self.userEmail setBorderForColor:nil width:0.0f radius:0.0f];
        
        [self requestChangeUserDetails:[self getJSONfromChangeUserDetails] completionHandler: ^ (void) {
            [CurrentItems sharedItems].user.name = self.userName.text;
            [CurrentItems sharedItems].user.email = self.userEmail.text;
        }];
    }
}

@end
