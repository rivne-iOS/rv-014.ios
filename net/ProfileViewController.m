//
//  ProfileViewController.m
//  net
//
//  Created by user on 2/10/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ProfileViewController.h"
#import "LogInViewController.h"
#import "UIColor+Bawl.h"
#import "User.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.changeUserDetails setBackgroundColor:[UIColor bawlRedColor03alpha]];
    [self.changeAvatar setBackgroundColor:[UIColor bawlRedColor03alpha]];
    
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2.0f;
    [self.profileImage clipsToBounds];
    
    self.navigationItem.rightBarButtonItem.title = @"Log In";
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
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
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
