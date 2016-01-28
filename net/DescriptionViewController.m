//
//  DescriptionViewController.m
//  net
//
//  Created by Admin on 19/01/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "DescriptionViewController.h"
#import "IssueChangeStatus.h"

@interface DescriptionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *currentStatusLabel;
@property (strong, nonatomic) IssueChangeStatus *statusChanger;

@end

@implementation DescriptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.statusChanger = [[IssueChangeStatus alloc] init];
}

-(void)setDataToView
{
    self.titleLabel.text = self.currentIssue.name;
    self.descriptionLabel.text = self.currentIssue.issueDescription;
    self.currentStatusLabel.text = [@"Current issue status is " stringByAppendingString:self.currentIssue.status];
}

#define SOME_OFFSET 8

-(void)prepareUIChangeStatusElements
{
    NSArray <NSString*> *strResults = [self.statusChanger newIssueStatusesForUser:[[User userStringRoles] objectAtIndex:self.currentUser.role] andCurretIssueStatus:self.currentIssue.status];
    
    if (strResults == nil)
        return;
    
    CGFloat x = self.currentStatusLabel.frame.origin.x;
    CGFloat y = self.currentStatusLabel.frame.origin.y + self.currentStatusLabel.frame.size.height + SOME_OFFSET;
    
    
#pragma warning Magic Numbers!!!
    UILabel *inviteLable = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.view.bounds.size.width - 30, 20)];
    inviteLable.text = @"If it's needed, you can change status to:";
    inviteLable.restorationIdentifier = @"dynamicItem";
    [self.view addSubview:inviteLable];
    
    y = y + inviteLable.bounds.size.height + SOME_OFFSET;
    
    for (NSString *strNewStatus in strResults)
    {
        UIButton *newStatusButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, 40, 20)];
        [newStatusButton setTitle:strNewStatus forState:UIControlStateNormal];
        [newStatusButton addTarget:self action:@selector(rerformChangeStatus) forControlEvents:UIControlEventTouchUpInside];
        [newStatusButton setBackgroundColor:[UIColor redColor]];
        newStatusButton.restorationIdentifier = @"dynamicItem";
        [self.view addSubview:newStatusButton];
    }
}

-(void)clearOldDynamicElements
{
    for (UIView *view in self.view.subviews)
    {
        if([view.restorationIdentifier isEqualToString:@"dynamicItem"])
        {
            [view removeFromSuperview];
        }
    }
}

-(void)rerformChangeStatus
{

}

@end
