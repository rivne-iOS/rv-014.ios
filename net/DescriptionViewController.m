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
#import "ChangerBox.h"
#import "CurrentItems.h"



@interface DescriptionViewController () <IssueImageDelegate>
@property (weak, nonatomic) IBOutlet UILabel *currentCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *issueImageView;

@property (strong, nonatomic) IssueChangeStatus *statusChanger;
@property (strong, nonatomic) id <DataSorceProtocol> dataSorce;

@property (strong, nonatomic) NSArray <NSString*> *stringNewStatuses;
@property (strong, nonatomic) UIView *viewToConnectChangeButtons;

@property (strong, nonatomic) UIView *backGreyView;
@property (strong, nonatomic) UIButton *changeButton;
@property (strong, nonatomic) NSMutableArray <ChangerBox*> *changerBoxArr;

@end

@implementation DescriptionViewController





-(NSMutableArray <ChangerBox*> *)changerBoxArr
{
    if(_changerBoxArr == nil)
        _changerBoxArr = [[NSMutableArray alloc] init];
    return _changerBoxArr;
}

-(IssueChangeStatus*)statusChanger
{
    if(_statusChanger == nil)
        _statusChanger = [[IssueChangeStatus alloc] init];
    return _statusChanger;
}

-(id<DataSorceProtocol>)dataSorce
{
    if(_dataSorce == nil)
        _dataSorce = [[NetworkDataSorce alloc] init];
    return _dataSorce;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self setDataToView];
    [self clearOldDynamicElements];
    [self prepareUIChangeStatusElements];
    [self.tabBarController.tabBar.items objectAtIndex:1].title = @"Description";
    
    CurrentItems *cItems = [CurrentItems sharedItems];
    if(cItems.issueImage==nil)
    {
        NSLog(@"if(cItems.issueImage==nil) in description");
        self.issueImageView.image = nil;
    }
     else if( ![self.issueImageView.image isEqual:cItems.issueImage])
    {
        NSLog(@"view will appear: ![self.issueImageView.image isEqual:cItems.issueImage], set uotlet.");
        self.issueImageView.image = cItems.issueImage;
    }
}

-(void)issueImageDidLoad
{
    CurrentItems *cItems = [CurrentItems sharedItems];
    if (![self.issueImageView.image isEqual:cItems.issueImage])
    {
        NSLog(@"in description issue did load: ![self.issueImageView.image isEqual:cItems.issueImage], setOutlet");
        dispatch_async(dispatch_get_main_queue(), ^{
           self.issueImageView.image = [CurrentItems sharedItems].issueImage; 
        });
        
    }
}



-(void)viewDidLoad
{
    CurrentItems *cItems = [CurrentItems sharedItems];
    [cItems.userImageDelegates addObject:self];
    [cItems.issueImageDelegates addObject:self];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor bawlRedColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(void)setDataToView
{
    self.titleLabel.text = [CurrentItems sharedItems].issue.name;
    self.titleLabel.textColor = [UIColor bawlRedColor];
    self.descriptionLabel.text = [CurrentItems sharedItems].issue.issueDescription;
    
    NSString *firstPart = @"Issue status: ";
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:[firstPart stringByAppendingString:[CurrentItems sharedItems].issue.status]];
    [aStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(firstPart.length, [aStr string].length - firstPart.length)];
    self.currentStatusLabel.attributedText = aStr;
    
    self.currentCategoryLabel.text = @"Loading category...";
    [self.dataSorce requestCategories:^(NSArray<IssueCategory *> *issueCategories) {
        for (IssueCategory *issueCategory in issueCategories)
        {
            
            if ([CurrentItems sharedItems].issue.categoryId.intValue ==  issueCategory.categoryId.intValue)
            {
                [self makeCategoryLabelWithStringCategory:issueCategory.name];
                break;
            }
        }
        
    } withErrorHandler:^(NSError *error) {
        // TODO: handle error
    }];
    
    
    
}


-(void)makeCategoryLabelWithStringCategory:(NSString*)stringCategory
{
    NSString *firstPart = @"Category: ";
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:[firstPart stringByAppendingString:stringCategory]];
    [aStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(firstPart.length, [aStr string].length - firstPart.length)];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentCategoryLabel.attributedText = aStr;
    });

}


#define SOME_OFFSET 8

-(void)prepareUIChangeStatusElements
{
    User *currentUser = [CurrentItems sharedItems].user;
    if (currentUser==nil)
        self.stringNewStatuses = nil;
    else
        self.stringNewStatuses = [self.statusChanger newIssueStatusesForUser:currentUser.stringRole andCurretIssueStatus:[CurrentItems sharedItems].issue.status];
    
    // just for testing
    // self.stringNewStatuses = @[@"111", @"222", @"333"];
    
    if (self.stringNewStatuses == nil)
        return;

    UIButton *changeButton = [[UIButton alloc] init];
    [changeButton setTitle:@"Change Status" forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(showNewStatuses) forControlEvents:UIControlEventTouchUpInside];
    [changeButton setBackgroundColor:[UIColor bawlRedColor]];
    [changeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [changeButton sizeToFit];
    changeButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:changeButton];
    [changeButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [changeButton.topAnchor constraintEqualToAnchor:self.currentStatusLabel.bottomAnchor constant:10.0].active = YES;
    [changeButton.heightAnchor constraintEqualToConstant:changeButton.frame.size.height].active = YES;
    [changeButton.widthAnchor constraintEqualToConstant:changeButton.frame.size.width+40].active = YES;
    self.changeButton = changeButton;

}

-(void)clearOldDynamicElements
{
    [self.changeButton removeFromSuperview];
    [self.backGreyView removeFromSuperview];
    
    for (ChangerBox *box in self.changerBoxArr)
    {
        [box.button removeFromSuperview];
        [box.label removeFromSuperview];
        [box.image removeFromSuperview];
    }
}



-(void)showNewStatuses
{
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor grayColor];
    backView.alpha = 0;
    backView.restorationIdentifier =@"dynamicItem showNewStatuses";
    backView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:backView];
    [backView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [backView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [backView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [backView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    self.backGreyView = backView;
    
#define CORNER_RADIUS 6

    ///cancel button
    ChangerBox *cancelBox = [[ChangerBox alloc] init];
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(rerformChangeStatus:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setBackgroundColor:[UIColor whiteColor]];
    [cancelButton setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    cancelButton.restorationIdentifier = @"cancel";
    cancelButton.alpha=0;
    [cancelButton sizeToFit];
    cancelButton.layer.cornerRadius = CORNER_RADIUS;
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    cancelBox.button = cancelButton;
    [self.changerBoxArr addObject:cancelBox];
    
    [self.view addSubview:cancelButton];
    [cancelButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active=YES;
    [cancelButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [cancelButton.topAnchor constraintEqualToAnchor:self.view.centerYAnchor].active=YES;
    self.viewToConnectChangeButtons = cancelButton;
    
    CGFloat firstOffset = 8;
    for (NSInteger a =self.stringNewStatuses.count; a>0; --a)
    {
        NSString *strNewStatus = [self.stringNewStatuses objectAtIndex:a-1];
        UIButton *newStatusButton = [[UIButton alloc] init];
        newStatusButton.restorationIdentifier = strNewStatus;
        [newStatusButton addTarget:self action:@selector(rerformChangeStatus:) forControlEvents:UIControlEventTouchUpInside];
        [newStatusButton setBackgroundColor:[UIColor whiteColor]];
        newStatusButton.alpha=0;
        [newStatusButton sizeToFit];
        newStatusButton.layer.cornerRadius = CORNER_RADIUS;
        newStatusButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIImageView *newStatusImage = [[UIImageView alloc] init];
        if ([strNewStatus isEqualToString:@"CANCELED"])
            newStatusImage.image = [UIImage imageNamed:@"description_status_CANCELED"];
        else
            newStatusImage.image = [UIImage imageNamed:@"description_status_yes"];
        newStatusImage.alpha=0;
        [newStatusImage sizeToFit];
        newStatusImage.translatesAutoresizingMaskIntoConstraints = NO;
        newStatusImage.userInteractionEnabled = NO;
        
        UILabel *newStatusLabel = [[UILabel alloc] init];
        NSString *mainText = [self.statusChanger labelTextForNewStatus:strNewStatus];
        newStatusLabel.text = mainText;
        
        NSString *addText = [self.statusChanger labelAdditionalTextForNewStatus:strNewStatus];
        if (addText != nil)
        {
            newStatusLabel.numberOfLines = 2;
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", mainText, addText]];
            [attr addAttribute:NSFontAttributeName value:[UIFont fontWithName:newStatusLabel.font.fontName size:newStatusLabel.font.pointSize-5] range:NSMakeRange(mainText.length+1, addText.length)];
            
            newStatusLabel.attributedText = attr;
        }
        
        newStatusLabel.backgroundColor = [UIColor clearColor];
        [newStatusLabel sizeToFit];
        newStatusLabel.alpha =0;
        newStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        newStatusLabel.userInteractionEnabled = NO;
        
        ChangerBox *box = [[ChangerBox alloc] initWithButton:newStatusButton andImage:newStatusImage andLabel:newStatusLabel];
        [self.changerBoxArr addObject:box];
        
        [self.view addSubview:newStatusButton];
        [newStatusButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active=YES;
        [newStatusButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        [newStatusButton.bottomAnchor constraintEqualToAnchor:self.viewToConnectChangeButtons.topAnchor constant:-firstOffset].active=YES;
        [newStatusButton.heightAnchor constraintEqualToConstant:newStatusButton.frame.size.height+15].active=YES;
        firstOffset = 1;
        self.viewToConnectChangeButtons = newStatusButton;
        
        [self.view addSubview:newStatusImage];
        [newStatusImage.leadingAnchor constraintEqualToAnchor:newStatusButton.leadingAnchor constant:15].active = YES;
        [newStatusImage.widthAnchor constraintEqualToConstant:30].active=YES;
        [newStatusImage.heightAnchor constraintEqualToConstant:30].active=YES;
        [newStatusImage.centerYAnchor constraintEqualToAnchor:newStatusButton.centerYAnchor].active=YES;
        
        [self.view addSubview:newStatusLabel];
        [newStatusLabel.leadingAnchor constraintEqualToAnchor:newStatusImage.trailingAnchor constant:15].active=YES;
        [newStatusLabel.trailingAnchor constraintEqualToAnchor:newStatusButton.trailingAnchor].active=YES;
        [newStatusLabel.centerYAnchor constraintEqualToAnchor:newStatusButton.centerYAnchor].active=YES;
        
        
    }
    
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         backView.alpha=0.7;
                     }];
    [UIView animateWithDuration:0.3
                          delay:0.15
                        options:0
                     animations:^{
                         for (ChangerBox *box in self.changerBoxArr)
                         {
                             box.button.alpha=1;
                             box.label.alpha=1;
                             box.image.alpha=1;
                         }
                     } completion:NULL];
    
    
}

-(void)rerformChangeStatus:(UIButton*)sender
{

    [UIView animateWithDuration:0.3
                     animations:^{
                         for (ChangerBox *box in self.changerBoxArr)
                         {
                             box.button.alpha=0;
                             box.label.alpha=0;
                             box.image.alpha=0;
                         }
                         
                     }];
    [UIView animateWithDuration:0.3
                          delay:0.15
                        options:0
                     animations:^{
                         self.backGreyView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self.backGreyView removeFromSuperview];
                         for (ChangerBox *box in self.changerBoxArr)
                         {
                             [box.button removeFromSuperview];
                             [box.label removeFromSuperview];
                             [box.image removeFromSuperview];
                         }
                         
                     }];
    
    
    
    

    
    if ([sender.restorationIdentifier isEqualToString:@"cancel"])
        return;
    
    [self.dataSorce requestChangeStatusWithID:[CurrentItems sharedItems].issue.issueId
                                     toStatus:sender.restorationIdentifier
                     andViewControllerHandler:^(NSString *stringAnswer, Issue *issue) {
                         dispatch_async(dispatch_get_main_queue(), ^ {
                             if (stringAnswer == nil)
                             {
                                 // good
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status change"
                                                                                 message:@"Status changed successfully!"
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"OK"
                                                                       otherButtonTitles:nil];
                                 [alert show];
                                 [CurrentItems sharedItems].issue = issue;
                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"renewMap" object:self];
                                 
                                 [self setDataToView];
                                 [self clearOldDynamicElements];
                                 [self prepareUIChangeStatusElements];
                                 
                             }
                             else
                             {
                                 // bad
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status change"
                                                                                 message:[NSString stringWithFormat:@"Fail to change, answer:%@", stringAnswer]
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"OK"
                                                                       otherButtonTitles:nil];
                                 [alert show];
                             }
                         });
                     } andErrorHandler:^(NSError *error) {
                         
                     }];
    
}
    
                             
                             
    
                         

@end
