//
//  MapViewController.m
//  net
//
//  Created by Admin on 11.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import "MapViewController.h"
#import "Issue.h"
#import "LogInViewController.h"

@interface MapViewController ()

@property(strong,nonatomic) NSArray *arrayOfPoints;
@property (weak, nonatomic) IBOutlet UITextView *userInfoText;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Map";
    self.userInfoText.text = @"There is no user";
    self.navigationItem.rightBarButtonItem.title = @"Log In";
    // [self updateUserInfoText];
    // Do any additional setup after loading the view.
}



-(void)setCurrentPerson:(User *) person
{
    _currentPerson = person;
    if(person == nil)
    {
        self.userInfoText.text = @"There is no user";
        self.navigationItem.rightBarButtonItem.title = @"Log In";

    }
    else
    {
        self.userInfoText.text = [person description];
        self.navigationItem.rightBarButtonItem.title = @"Sing Out";
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"fromMapToLogIn"])
    {
        if([segue.destinationViewController isKindOfClass:[LogInViewController class]])
        {
            LogInViewController *logInVC = (LogInViewController*)segue.destinationViewController;
            logInVC.mapDelegate = self;
            
        }
    }
}


@end
