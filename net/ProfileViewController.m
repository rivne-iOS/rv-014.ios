//
//  ProfileViewController.m
//  net
//
//  Created by user on 2/10/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ProfileViewController.h"
#import "LogInViewController.h"
#import "DataSorceProtocol.h"
#import "UIColor+Bawl.h"
#import "User.h"

@interface ProfileViewController ()

@property (nonatomic, weak) IBOutlet UILabel *labelUserLogin;
@property (nonatomic, weak) IBOutlet UILabel *labelSystemRole;
@property (nonatomic, weak) IBOutlet UILabel *labelUserEmail;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.changeUserDetails setBackgroundColor:[UIColor bawlRedColor03alpha]];
    [self.changeAvatar setBackgroundColor:[UIColor bawlRedColor03alpha]];
    
    [self hideAllViews];
    
    self.navigationItem.rightBarButtonItem.title = @"Log In";
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tabBarController.tabBar setHidden:YES];
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2.0f;
    self.profileImage.clipsToBounds = YES;

    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
    
    [self hideAllViews];
    
    [self requestUserDetailsByID:self.userID updateScreenWithHandler:^(User *user){
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self.userLogin setText:user.login];
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
            [self.activityIndicatorView stopAnimating];
            self.activityIndicatorView.hidden = YES;
            
            [self revialAllViews];
        });
    }];
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

- (void) revialAllViews {
    [self.profileImage setHidden:NO];
    [self.userName setHidden:NO];
    [self.labelUserLogin setHidden:NO];
    [self.userLogin setHidden:NO];
    [self.labelUserEmail setHidden:NO];
    [self.userEmail setHidden:NO];
    [self.labelSystemRole setHidden:NO];
    [self.systemRole setHidden:NO];
    [self.changeUserDetails setHidden:NO];
    [self.changeAvatar setHidden:NO];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"fromMapToLogIn"])
    {
        if([segue.destinationViewController isKindOfClass:[LogInViewController class]])
        {
            LogInViewController *logInVC = (LogInViewController*)segue.destinationViewController;
        }
    }
}


@end
