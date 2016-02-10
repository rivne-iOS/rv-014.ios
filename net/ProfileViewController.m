//
//  ProfileViewController.m
//  net
//
//  Created by user on 2/10/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ProfileViewController.h"
#import "LogInViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.title = @"Log In";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
