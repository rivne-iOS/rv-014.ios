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
#import "DescriptionViewController.h"
#import "UIScrollView+getContentSize.h"
#import "NetworkDataSorce.h"

static NSString const * const AVATAR_NO_IMAGE = @"no_avatar.png";
static NSString const * const DOMAIN_CHANGE_USER_DETAILS = @"https://bawl-rivne.rhcloud.com/users/";
static NSInteger const HTTP_RESPONSE_CODE_OK = 200;

@interface ProfileViewController ()

@property (nonatomic, weak) IBOutlet UILabel *labelUserLogin;
@property (nonatomic, weak) IBOutlet UILabel *labelSystemRole;
@property (nonatomic, weak) IBOutlet UILabel *labelUserEmail;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIImage *avatarImage;
@property (strong, nonatomic) NSString *avatarImageURL;
@property (strong, nonatomic) UITextField *activeField;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)];
    
    [self.view addGestureRecognizer:tap];
    
    [self.changeUserDetails setBackgroundColor:[UIColor bawlRedColor]];
    [self.changeAvatar setBackgroundColor:[UIColor bawlRedColor]];
    
    [self.progressView setAlpha:0.0];
    
    [self registerForKeyboardNotifications];
    
    self.userEmail.delegate = self;
    self.userName.delegate = self;
    
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
    
    if ([[self backViewController] isKindOfClass:[IssueHistoryViewController class]] ||
        [[self backViewController] isKindOfClass:[DescriptionViewController class]]) {
    
        if ([CurrentItems sharedItems].user && (self.userID == [CurrentItems sharedItems].user.userId)) {
            [self setUserProfileDetails:[CurrentItems sharedItems].user isLoggedUser:YES];
            [self revealAllViews];
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
        [self revealAllViews];
    }
    
//    [self.mapViewDelegate hideTabBar];
    self.tabBarController.tabBar.hidden = YES;
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2.0f;
    self.profileImage.clipsToBounds = YES;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    if([CurrentItems sharedItems].issue != nil)
        self.tabBarController.tabBar.hidden = NO;
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
        
        if ([[self backViewController] isKindOfClass:[IssueHistoryViewController class]] ||
            [[self backViewController] isKindOfClass:[DescriptionViewController class]]) {
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
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      
                      if (error) {
                          [weakSelf.progressView setProgress:0.0];
                          [UIView animateWithDuration:1.0 animations:^(void) {
                              [weakSelf.progressView  setAlpha:0.0];
                          }];
                          NSLog(@"Error: %@", error);
                      } else {
                          NSLog(@"%@ %@", response, responseObject);
                          NSDictionary *JSONdic = [[NSDictionary alloc] initWithObjectsAndKeys: responseObject[@"filename"],@"avatar", nil];
                          
                          [weakSelf requestChangeUserDetails:JSONdic completionHandler:^(void){
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [CurrentItems sharedItems].userImage = profileImage;
                                  [weakSelf.profileImage setImage:profileImage];
                                  [weakSelf.progressView setProgress:0.0];
                                  
                                  [UIView animateWithDuration:1.0 animations:^(void) {
                                      [weakSelf.progressView  setAlpha:0.0];
                                  }];
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
        [self.userName setEnabled:YES];
        [self.userEmail setEnabled:YES];
        
        [self.userName setBorderForColor:[UIColor bawlRedColor03alpha] width:0.5f radius:5.0f];
        [self.userEmail setBorderForColor:[UIColor bawlRedColor03alpha] width:0.5f radius:5.0f];
    }
    else if ([sender.titleLabel.text isEqualToString:@"Save"]) {
        [self.changeUserDetails setTitle:@"Change User Details" forState:UIControlStateNormal];
        [self.userName setEnabled:NO];
        [self.userEmail setEnabled:NO];
        
        [self.userName setBorderForColor:nil width:0.0f radius:0.0f];
        [self.userEmail setBorderForColor:nil width:0.0f radius:0.0f];
        
        [self requestChangeUserDetails:[self getJSONfromChangeUserDetails] completionHandler: ^ (void) {
            [CurrentItems sharedItems].user.name = self.userName.text;
            [CurrentItems sharedItems].user.email = self.userEmail.text;
        }];
    }
}

#pragma mark - Keyboard
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardDidShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(80, 0.0, aRect.size.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;

    CGPoint point = [self.activeField.superview convertPoint:self.activeField.frame.origin toView:nil];
    
    point.y += self.activeField.frame.size.height;
    
    if (!CGRectContainsPoint(aRect, point) ) {
        [self.scrollView setContentOffset:CGPointMake(0.0, point.y - aRect.size.height) animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    contentInsets.top = 80;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.activeField resignFirstResponder];
}

@end
