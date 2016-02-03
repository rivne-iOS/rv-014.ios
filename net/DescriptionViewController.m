//
//  DescriptionViewController.m
//  net
//
//  Created by Admin on 19/01/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "UIColor+Bawl.h"
#import "DescriptionViewController.h"
#import "IssueChangeStatus.h"
#import "NetworkDataSorce.h"

@interface DescriptionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *currentStatusLabel;
@property (strong, nonatomic) IssueChangeStatus *statusChanger;
@property (strong, nonatomic) id <DataSorceProtocol> dataSorce;

@property (strong, nonatomic) NSArray <NSString*> *stringNewStatuses;
@property (strong, nonatomic) UIView *viewToConnectChangeButtons;


@end

@implementation DescriptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.statusChanger = [[IssueChangeStatus alloc] init];
    self.dataSorce = [[NetworkDataSorce alloc] init];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self setDataToView];
    [self clearOldDynamicElements];
    [self prepareUIChangeStatusElements];

}

-(void)setDataToView
{
    self.titleLabel.text = self.currentIssue.name;
    self.descriptionLabel.text = self.currentIssue.issueDescription;
    
    NSString *firstPart = @"Issue status: ";
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:[firstPart stringByAppendingString:self.currentIssue.status]];
    [aStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(firstPart.length, [aStr string].length - firstPart.length)];
    self.currentStatusLabel.attributedText = aStr;
}

#define SOME_OFFSET 8

-(void)prepareUIChangeStatusElements
{
    self.stringNewStatuses = [self.statusChanger newIssueStatusesForUser:[[User userStringRoles] objectAtIndex:self.currentUser.role] andCurretIssueStatus:self.currentIssue.status];
    
//    self.stringNewStatuses = @[@"111", @"222", @"333"];
    
    if (self.stringNewStatuses == nil)
        return;
    
    
    
    
    
//     self.viewToConnectChangeButtons = inviteLable1;

    UIButton *changeButton = [[UIButton alloc] init];
    [changeButton setTitle:@"Change status" forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(showNewStatuses) forControlEvents:UIControlEventTouchUpInside];
    [changeButton setBackgroundColor:[UIColor bawlRedColor]];
    [changeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    changeButton.restorationIdentifier = @"dynamicItem";
    [changeButton sizeToFit];
    changeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:changeButton];
    [changeButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [changeButton.topAnchor constraintEqualToAnchor:self.currentStatusLabel.bottomAnchor].active = YES;
    self.viewToConnectChangeButtons = changeButton;
    

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

-(void)showNewStatuses
{
    NSMutableArray <UIButton*> *changeButtons = [[NSMutableArray alloc] init];
    for (NSString *strNewStatus in self.stringNewStatuses)
    {
        UIButton *newStatusButton = [[UIButton alloc] init];
        [newStatusButton setTitle:strNewStatus forState:UIControlStateNormal];
        [newStatusButton addTarget:self action:@selector(rerformChangeStatus:) forControlEvents:UIControlEventTouchUpInside];
        [newStatusButton setBackgroundColor:[UIColor whiteColor]];
        [newStatusButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
        newStatusButton.restorationIdentifier = @"dynamicItem";
        [newStatusButton sizeToFit];
        newStatusButton.translatesAutoresizingMaskIntoConstraints = NO;
        newStatusButton.backgroundColor = nil;
        newStatusButton.alpha=0;
        [changeButtons addObject:newStatusButton];
        
        [self.view addSubview:newStatusButton];
        [newStatusButton.leadingAnchor constraintEqualToAnchor:self.viewToConnectChangeButtons.leadingAnchor].active=YES;
        NSLayoutConstraint *c = [newStatusButton.topAnchor constraintEqualToAnchor:self.viewToConnectChangeButtons.bottomAnchor constant:-(self.viewToConnectChangeButtons.frame.size.height)];
        self.viewToConnectChangeButtons = newStatusButton;
        c.active = YES;
        c.identifier = @"constraintOfTopAnchor";

    }
    [self.view layoutIfNeeded];
    
    __weak UIView * v = self.view;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGFloat offsetFirstButton = 0;
                         CGFloat offsetButton = 0;
                         for (NSUInteger a = 0; a < changeButtons.count; ++a)
                         {
                             
                             [changeButtons objectAtIndex:a].alpha=1.0;
                             for (NSLayoutConstraint *c in v.constraints)
                             {
                                 if ([c.identifier isEqualToString:@"constraintOfTopAnchor"] && c.firstItem == [changeButtons objectAtIndex:a])
                                 {
                                     c.constant = offsetButton + offsetFirstButton;
                                     offsetFirstButton = 0;
                                     [self.view layoutIfNeeded];
                                     break;
                                 }
                             }
                         }
 
                     }
                     completion:^(BOOL finished) {
                     }];
    

    
    
}



-(void)rerformChangeStatus:(UIButton*)sender
{
    
    [self.dataSorce requestChangeStatusWithID:self.currentIssue.issueId
                                     toStatus:sender.currentTitle
                     andViewControllerHandler:^(NSString *stringAnswer, Issue *issue) {
                         dispatch_async(dispatch_get_main_queue(), ^ {
                             if (stringAnswer == nil)
                             {
                                 // good
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                                                 message:@"Status changed successfully!"
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"I understood"
                                                                       otherButtonTitles:nil];
                                 [alert show];
                                 self.currentIssue = issue;
                                 self.currentMarker.userData = issue;
                                 [self setDataToView];
                                 [self clearOldDynamicElements];
                                 [self prepareUIChangeStatusElements];
                                 
                             }
                             else
                             {
                                 // bad
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                                                 message:[NSString stringWithFormat:@"Fail to change, answer:%@", stringAnswer]
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"I understood"
                                                                       otherButtonTitles:nil];
                                 [alert show];
                             }
                         });
                     } andErrorHandler:^(NSError *error) {
                         
                     }];
    
}
    
                             
                             
    
                         

@end
