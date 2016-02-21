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
#import "IssueCategories.h"
#import "AvatarView.h"
#import "Comment.h"



@interface DescriptionViewController () <IssueImageDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *issueImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *commentLabelOnButton;
@property (weak, nonatomic) IBOutlet UIImageView *changeStatusArrow;
@property (weak, nonatomic) IBOutlet UIView *viewBetweenCommentAndChare;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *ScrollView;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *constraintsVertical;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewsVertical;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;




@property (strong, nonatomic) IssueChangeStatus *statusChanger;
@property (strong, nonatomic) id <DataSorceProtocol> dataSorce;

@property (strong, nonatomic) NSArray <NSString*> *stringNewStatuses;
@property (strong, nonatomic) UIView *viewToConnectDynamicItems;

@property (strong, nonatomic) UIView *backGreyView;
@property (strong, nonatomic) UIButton *changeButton;
@property (strong, nonatomic) NSMutableArray <ChangerBox*> *changerBoxArr;

@property(nonatomic) CGFloat avatarSize;
@property(nonatomic) CGFloat contentStaticHeight;
@property(nonatomic) CGFloat contentDynamicHeight;

@end

@implementation DescriptionViewController



#pragma mark - Lasy instantiation

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

#pragma mark - View appear / disappear (+ loading data)

-(void)viewDidLoad
{
    
    CurrentItems *cItems = [CurrentItems sharedItems];
    [cItems.issueImageDelegates addObject:self];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor bawlRedColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.avatarSize = self.contentView.frame.size.width / 10;
}

- (void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    CurrentItems *cItems = [CurrentItems sharedItems];
    self.title = cItems.appTitle;
    [self setDataToView];
    [self clearOldDynamicElements];
    [self prepareUIChangeStatusElements];
    [self.tabBarController.tabBar.items objectAtIndex:1].title = @"Description";
    
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
    
    
    [self requestUsersAndComments];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self calculateContentViewStaticHeight];
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

-(void)calculateContentViewStaticHeight
{
    self.contentStaticHeight = 0;
    for (UIView *view in self.viewsVertical)
    {
        self.contentStaticHeight += view.frame.size.height;
        NSLog(@"append view height: %f",view.frame.size.height);
    }
    for (NSLayoutConstraint *con in self.constraintsVertical)
    {
        self.contentStaticHeight += con.constant;
        NSLog(@"append consthaint height: %f",con.constant);
        
    }

}


-(void)setDataToView
{
    Issue *currentIssue = [CurrentItems sharedItems].issue;
    self.titleLabel.text = currentIssue.name;
    self.titleLabel.textColor = [UIColor bawlRedColor];
    self.descriptionLabel.text = currentIssue.issueDescription;
    self.currentStatusLabel.text = currentIssue.status;
    
    self.categoryImageView.image = [[IssueCategories standartCategories] imageForCurrentCategory];
}

-(void)orientationChanged:(NSNotification*)notification
{
    [self calculateContentViewStaticHeight];
    self.contentViewHeightConstraint.constant  = self.contentStaticHeight + self.contentDynamicHeight;
    
}


#pragma mark - Dynamic elements

-(void)requestUsersAndComments
{
    __weak DescriptionViewController *weakSelf = self;
    [self.dataSorce requestAllUsers:^(NSArray<NSDictionary<NSString *,NSString *> *> *userDictionaries) {
        [weakSelf commentBlockWithAllUserDictionaries:userDictionaries];
    } withErrorHandler:^(NSError *error) {
        //error
    }];
}


-(void)commentBlockWithAllUserDictionaries:(NSArray<NSDictionary<NSString *,NSString *> *> *) allUserDictionaries
{
    __weak DescriptionViewController *weakSelf = self;
    self.viewToConnectDynamicItems = self.viewBetweenCommentAndChare;
    
    [self.dataSorce requestComments:^(NSArray<NSDictionary<NSString *,id> *> *commentDics) {
       dispatch_async(dispatch_get_main_queue(), ^{
           self.contentDynamicHeight = 0;
           for (NSDictionary<NSString *,id> *commentDic in commentDics)
           {
               
               UIView *commentBox = [[UIView alloc] init];
               commentBox.translatesAutoresizingMaskIntoConstraints = NO;
               
               [weakSelf.contentView addSubview:commentBox];
               [commentBox.topAnchor constraintEqualToAnchor:weakSelf.viewToConnectDynamicItems.bottomAnchor].active = YES;
               [commentBox.leadingAnchor constraintEqualToAnchor:weakSelf.contentView.leadingAnchor constant:8].active = YES;
               [commentBox.heightAnchor constraintEqualToConstant:weakSelf.avatarSize+10].active = YES;
               [commentBox.trailingAnchor constraintEqualToAnchor:weakSelf.contentView.trailingAnchor constant:-8].active = YES;
//                commentBox.layer.borderColor = [[UIColor blackColor] CGColor];
//                commentBox.layer.borderWidth = 1;
               weakSelf.viewToConnectDynamicItems = commentBox;
               weakSelf.contentDynamicHeight += weakSelf.avatarSize+10;
               
               AvatarView *avatar = [[AvatarView alloc] init];
               avatar.translatesAutoresizingMaskIntoConstraints = NO;
//               avatar.layer.borderColor = [[UIColor blackColor] CGColor];
//               avatar.layer.borderWidth = 1;
               
               [commentBox addSubview:avatar];
               [avatar.widthAnchor constraintEqualToConstant:weakSelf.avatarSize].active = YES;
               [avatar.heightAnchor constraintEqualToConstant:weakSelf.avatarSize].active = YES;
               [avatar.leadingAnchor constraintEqualToAnchor:commentBox.leadingAnchor constant:5].active = YES;
               [avatar.centerYAnchor constraintEqualToAnchor:commentBox.centerYAnchor].active = YES;
               
               Comment *comment = [[Comment alloc] initWithCommentDictionary:commentDic andAllUsersDictionaries:allUserDictionaries andUIImageView:(UIImageView*)avatar];
               
               UILabel *commentLabelName = [[UILabel alloc] init];
               commentLabelName.translatesAutoresizingMaskIntoConstraints = NO;
               commentLabelName.text = comment.userName;
//               commentLabelName.layer.borderWidth = 1;
//               commentLabelName.layer.borderColor = [[UIColor redColor] CGColor];
               // [commentLabelName sizeToFit];
               
               [commentBox addSubview:commentLabelName];
               [commentLabelName.leadingAnchor constraintEqualToAnchor:avatar.trailingAnchor constant:5].active = YES;
               [commentLabelName.topAnchor constraintEqualToAnchor:avatar.topAnchor].active = YES;
               [commentLabelName.trailingAnchor constraintEqualToAnchor:commentBox.trailingAnchor].active=YES;
//               weakSelf.contentHeight += commentLabelName.frame.size.height;
               
               UILabel *commentLabelMessage = [[UILabel alloc] init];
               commentLabelMessage.translatesAutoresizingMaskIntoConstraints = NO;
               commentLabelMessage.text = comment.userMessage;
               commentLabelMessage.numberOfLines = 0;
               UIFont *oldFont = commentLabelMessage.font;
               commentLabelMessage.font = [UIFont fontWithName:oldFont.fontName size:oldFont.pointSize-5];
               [commentLabelMessage sizeToFit];
//               commentLabelMessage.layer.borderWidth = 1;
//               commentLabelMessage.layer.borderColor = [[UIColor blueColor] CGColor];
               
               [commentBox addSubview:commentLabelMessage];
               [commentLabelMessage.leadingAnchor constraintEqualToAnchor:avatar.trailingAnchor constant:5].active = YES;
               [commentLabelMessage.topAnchor constraintEqualToAnchor:commentLabelName.bottomAnchor].active = YES;
               [commentLabelMessage.trailingAnchor constraintEqualToAnchor:commentBox.trailingAnchor].active = YES;
               [commentLabelMessage.bottomAnchor constraintEqualToAnchor:avatar.bottomAnchor].active = YES;
//               weakSelf.contentHeight += commentLabelMessage.frame.size.height;
           }
           NSLog(@"weakSelf.viewBetweenCommentAndChare %@",weakSelf.viewBetweenCommentAndChare);
           weakSelf.contentViewHeightConstraint.constant = weakSelf.contentDynamicHeight + weakSelf.contentStaticHeight;
           // weakSelf.ScrollView.contentSize = CGSizeMake(weakSelf.contentView.frame.size.width, weakSelf.contentHeight);
           
       });
        
    } withErrorHandler:^(NSError *error) {
        // error
    }];
    
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
    {
        self.changeStatusArrow.hidden = YES;
    }
    else
    {
        self.changeStatusArrow.hidden = NO;
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
    self.viewToConnectDynamicItems = cancelButton;
    
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
        [newStatusButton.bottomAnchor constraintEqualToAnchor:self.viewToConnectDynamicItems.topAnchor constant:-firstOffset].active=YES;
        [newStatusButton.heightAnchor constraintEqualToConstant:newStatusButton.frame.size.height+15].active=YES;
        firstOffset = 1;
        self.viewToConnectDynamicItems = newStatusButton;
        
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
