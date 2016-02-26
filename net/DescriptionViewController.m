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
#import "CommentBox.h"



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

@property (strong, nonatomic) IBOutlet UIButton *changeButton;


@property (strong, nonatomic) IssueChangeStatus *statusChanger;
@property (strong, nonatomic) id <DataSorceProtocol> dataSorce;

@property (strong, nonatomic) NSArray <NSString*> *stringNewStatuses;
@property (strong, nonatomic) UIView *viewToConnectDynamicItems;

@property (strong, nonatomic) UIView *backGreyView;
@property (strong, nonatomic) NSMutableArray <ChangerBox*> *changerBoxArr;
@property (strong, nonatomic) NSMutableArray <CommentBox*> *commentBoxArr;

@property(nonatomic) CGFloat avatarSize;
@property(nonatomic) CGFloat contentStaticHeight;
@property(nonatomic) CGFloat contentDynamicHeight;


@property(strong,nonatomic) UITextField *addCommentDynamicTextField;
@property(strong, nonatomic) UIView *addCommentDynamicGreyView;
@property(strong, nonatomic) UIButton *addCommentDynamicButton;

@end

@implementation DescriptionViewController



#pragma mark - Lasy instantiation


-(NSMutableArray <CommentBox*> *)commentBoxArr
{
    if(_commentBoxArr==nil)
        _commentBoxArr = [[NSMutableArray alloc] init];
    return _commentBoxArr;
}


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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
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


#pragma mark - actions

- (IBAction)changeStatus:(UIButton *)sender
{
    [self showNewStatuses];
}

- (IBAction)addNewComment:(UIButton *)sender
{
    UITextField *addCommentTextField = [[UITextField alloc] init];
    addCommentTextField.translatesAutoresizingMaskIntoConstraints = NO;
    addCommentTextField.backgroundColor = [UIColor whiteColor];

    self.addCommentDynamicTextField = addCommentTextField;
    [self.view addSubview:addCommentTextField];
    [addCommentTextField becomeFirstResponder];
}

-(NSLayoutConstraint*)scrollBottomConstraint
{
    for(NSLayoutConstraint *constraint in self.view.constraints)
    {
        if ([constraint.identifier isEqualToString:@"BottomScrollViewConstraint"])
        {
            return constraint;
            
        }
    }
    return nil;
    
}

-(void)keyboardDidShow:(NSNotification *)notification
{
    if (self.addCommentDynamicTextField == nil)
        return;
    
    UIView *grayView = [[UIView alloc] init];
    grayView.translatesAutoresizingMaskIntoConstraints = NO;
    grayView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    self.addCommentDynamicGreyView = grayView;
    
    UIButton *addCommentButton = [[UIButton alloc] init];
    addCommentButton.translatesAutoresizingMaskIntoConstraints = NO;
    [addCommentButton addTarget:self action:@selector(sendCommentPressed) forControlEvents:UIControlEventTouchUpInside];
    NSString *buttonTitle = @"Send";
    [addCommentButton setTitle:buttonTitle forState:UIControlStateNormal];
    [addCommentButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    self.addCommentDynamicButton = addCommentButton;
    
    NSDictionary *dic = notification.userInfo;
    NSValue *keyboardFrame = dic[UIKeyboardFrameEndUserInfoKey];
    CGRect frame = [keyboardFrame CGRectValue];
    CGRect viewFrame = [self.view convertRect:frame fromView:nil];
    CGFloat keyboardHeight = viewFrame.size.height;
    
    CGFloat textFieldHeight = 60;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGSize buttonTittleSize = [buttonTitle sizeWithAttributes:@{NSFontAttributeName : addCommentButton.titleLabel.font}];
    
    self.addCommentDynamicTextField.layer.cornerRadius = self.addCommentDynamicTextField.frame.size.height / 4;
    
    [self scrollBottomConstraint].constant = keyboardHeight + textFieldHeight - tabBarHeight;
    [self.view layoutIfNeeded];
    
    [self.view insertSubview:grayView belowSubview:self.addCommentDynamicTextField];
    [self.view addSubview:addCommentButton];
    [addCommentButton sizeToFit];
    
    [grayView.topAnchor constraintEqualToAnchor:self.ScrollView.bottomAnchor].active = YES;
    [grayView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [grayView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [grayView.heightAnchor constraintEqualToConstant:textFieldHeight].active = YES;
    
    [self.addCommentDynamicTextField.topAnchor constraintEqualToAnchor:grayView.topAnchor constant:2].active = YES;
    [self.addCommentDynamicTextField.leadingAnchor constraintEqualToAnchor:grayView.leadingAnchor constant:8].active = YES;
    [self.addCommentDynamicTextField.trailingAnchor constraintEqualToAnchor:addCommentButton.leadingAnchor constant:-8].active = YES;
    [self.addCommentDynamicTextField.bottomAnchor constraintEqualToAnchor:grayView.bottomAnchor constant:-2].active = YES;
    
    [addCommentButton.trailingAnchor constraintEqualToAnchor:grayView.trailingAnchor constant:-8].active = YES;
    [addCommentButton.centerYAnchor constraintEqualToAnchor:self.addCommentDynamicTextField.centerYAnchor].active = YES;
    [addCommentButton.widthAnchor constraintEqualToConstant:buttonTittleSize.width+4].active = YES;
    
    
    [UIView animateWithDuration:0.3 animations:^{
        self.ScrollView.contentOffset = CGPointMake(0, self.contentView.frame.size.height - self.ScrollView.frame.size.height);
    }];
    
    
    
    
}

-(void)keyboardWillHide
{
    [self scrollBottomConstraint].constant = 0;
    [self.view layoutIfNeeded];
    
}

-(void)sendCommentPressed
{
    NSString *message = self.addCommentDynamicTextField.text;
    [self.addCommentDynamicTextField resignFirstResponder];
    [self.addCommentDynamicButton removeFromSuperview];
    [self.addCommentDynamicGreyView removeFromSuperview];
    [self.addCommentDynamicGreyView removeFromSuperview];
    
    self.addCommentDynamicButton = nil;
    self.addCommentDynamicButton = nil;
    self.addCommentDynamicButton = nil;
    
    [self requestUsersAndAddNewCommentsAndSendMessage:message];
    
}

-(void)requestUsersAndAddNewCommentsAndSendMessage:(NSString*)message
{
    __weak DescriptionViewController *weakSelf = self;
    [self.dataSorce requestAllUsers:^(NSArray<NSDictionary<NSString *,NSString *> *> *userDictionaries) {
        [weakSelf sendMessage:message andAddnewCommentsBlockWithAllUserDictionaries:userDictionaries];
    } withErrorHandler:^(NSError *error) {
        //error
    }];
}

-(void)sendMessage:(NSString*)message andAddnewCommentsBlockWithAllUserDictionaries:(NSArray<NSDictionary<NSString *,NSString *> *> *) allUserDictionaries
{
    __weak DescriptionViewController *weakSelf = self;
    
    [self.dataSorce requestSendNewComment:message
    forIssueID:[CurrentItems sharedItems].issue.issueId
    andHandler:^(NSArray<NSDictionary<NSString *,id> *> *commentDics, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
           if(commentDics==nil || error != nil)
               return;
           
           for (NSInteger index=self.commentBoxArr.count; index<commentDics.count; ++index)
           {
               
               NSDictionary<NSString *,id> *commentDic = commentDics[index];
               [weakSelf addOneComment:commentDic withIndex:index allUsersDic:allUserDictionaries];
           }
           NSLog(@"weakSelf.viewBetweenCommentAndChare %@",weakSelf.viewBetweenCommentAndChare);
           weakSelf.contentViewHeightConstraint.constant = weakSelf.contentDynamicHeight + weakSelf.contentStaticHeight;
           [weakSelf.view layoutIfNeeded];
            
            [UIView animateWithDuration:0.3 animations:^{
                self.ScrollView.contentOffset = CGPointMake(0, self.contentView.frame.size.height - self.ScrollView.frame.size.height);
            }];
        });
    }];
    
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
    
    [self.dataSorce requestCommentsWithIssueID:[CurrentItems sharedItems].issue.issueId
                                    andHandler:^(NSArray<NSDictionary<NSString *,id> *> *commentDics, NSError *error) {
       dispatch_async(dispatch_get_main_queue(), ^{
           weakSelf.contentViewHeightConstraint.constant =  weakSelf.contentStaticHeight;
           [weakSelf.view layoutIfNeeded];
           if(commentDics==nil || error != nil || [commentDics isKindOfClass: [NSDictionary class]])
               return;
           weakSelf.contentDynamicHeight = 0;
           weakSelf.contentView.restorationIdentifier = @"contentView";
           for (NSInteger index=0; index<commentDics.count; ++index)
           {
               
               NSDictionary<NSString *,id> *commentDic = commentDics[index];
               [weakSelf addOneComment:commentDic withIndex:index allUsersDic:allUserDictionaries];
           }
           NSLog(@"weakSelf.viewBetweenCommentAndChare %@",weakSelf.viewBetweenCommentAndChare);
           weakSelf.contentViewHeightConstraint.constant = weakSelf.contentDynamicHeight + weakSelf.contentStaticHeight;
           [weakSelf.view layoutIfNeeded];
       });
    }];
    
}

-(void)addOneComment:(NSDictionary <NSString*, id> *)commentDic withIndex:(NSInteger)index allUsersDic:(NSArray <NSDictionary <NSString*,id> *> *)allUsersDictionaries
{
    CommentBox *box = [[CommentBox alloc] init];
    UIView *commentView = [[UIView alloc] init];
    UIView *commentView2 = [[UIView alloc] init];
    AvatarView *avatar = [[AvatarView alloc] init];
    UIButton *buttonAvatar = [[UIButton alloc] init];
    UILabel *commentLabelName = [[UILabel alloc] init];
    UIButton *buttonCommentName = [[UIButton alloc] init];
    UILabel *commentLabelMessage = [[UILabel alloc] init];
    UIButton *buttonCommentMessage = [[UIButton alloc] init];
    
    [self.commentBoxArr addObject:box];
    
    box.isBig = NO;
    //commentView
    commentView.translatesAutoresizingMaskIntoConstraints = NO;
    commentView.restorationIdentifier = @"commentView";
    box.commentView = commentView;
    
    [self.contentView addSubview:commentView];
    box.firstZPos = commentView.layer.zPosition;
    [commentView.topAnchor constraintEqualToAnchor:self.viewToConnectDynamicItems.bottomAnchor].active = YES;
    [commentView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8].active = YES;
    [commentView.heightAnchor constraintEqualToConstant:self.avatarSize+10].active = YES;
    [commentView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8].active = YES;
    self.viewToConnectDynamicItems = commentView;
    self.contentDynamicHeight += self.avatarSize+10;
    
    //commentView2
    commentView2.hidden = YES;
    commentView2.alpha = 0;
    commentView2.translatesAutoresizingMaskIntoConstraints = NO;
    commentView2.backgroundColor = [UIColor whiteColor];
    commentView2.layer.borderColor = [[[UIColor blackColor] colorWithAlphaComponent:0.4] CGColor];
    commentView2.layer.borderWidth = 1;
    box.commentView2 = commentView2;
    
    [self.contentView addSubview:commentView2];
    
    //Avatar
    avatar.translatesAutoresizingMaskIntoConstraints = NO;
    avatar.restorationIdentifier = @"AvatarImageView";
    //               avatar.backgroundColor = [UIColor yellowColor];
    box.avatar = avatar;
    
    [self.contentView addSubview:avatar];
    [avatar.widthAnchor constraintEqualToConstant:self.avatarSize].active = YES;
    [avatar.heightAnchor constraintEqualToConstant:self.avatarSize].active = YES;
    
    NSMutableArray <NSLayoutConstraint*> *avatarConstraints = [[NSMutableArray alloc] init];
    [avatarConstraints addObject:[avatar.leadingAnchor constraintEqualToAnchor:commentView.leadingAnchor]];
    [avatarConstraints addObject:[avatar.centerYAnchor constraintEqualToAnchor:commentView.centerYAnchor]];
    for (NSLayoutConstraint *con in avatarConstraints)
        con.active=YES;
    box.avatarConstraints = avatarConstraints;
    
    NSMutableArray <NSLayoutConstraint*> *avatarConstraintsBig = [[NSMutableArray alloc] init];
    [avatarConstraintsBig addObject:[avatar.bottomAnchor constraintEqualToAnchor:commentLabelMessage.topAnchor constant:-8]];
    [avatarConstraintsBig addObject:[avatar.leadingAnchor constraintEqualToAnchor:commentLabelMessage.leadingAnchor]];
    box.avatarConstraintsBig = avatarConstraintsBig;
    
    //button Avatar
    buttonAvatar.translatesAutoresizingMaskIntoConstraints = NO;
    buttonAvatar.restorationIdentifier = @"buttonAvatarImageView";
    box.buttonImage = buttonAvatar;
    [buttonAvatar addTarget:self action:@selector(commentAvatarTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:buttonAvatar];
    [buttonAvatar.topAnchor constraintEqualToAnchor:avatar.topAnchor].active=YES;
    [buttonAvatar.bottomAnchor constraintEqualToAnchor:avatar.bottomAnchor].active=YES;
    [buttonAvatar.leadingAnchor constraintEqualToAnchor:avatar.leadingAnchor].active=YES;
    [buttonAvatar.trailingAnchor constraintEqualToAnchor:avatar.trailingAnchor].active=YES;
    
    //comment init with image View
    Comment *comment = [[Comment alloc] initWithCommentDictionary:commentDic andAllUsersDictionaries:allUsersDictionaries andUIImageView:(UIImageView*)avatar];
    
    // Name label
    commentLabelName.translatesAutoresizingMaskIntoConstraints = NO;
    commentLabelName.restorationIdentifier = @"commentNameLabel";
    commentLabelName.text = comment.userName;
    //               commentLabelName.backgroundColor = [UIColor yellowColor];
    box.commentLabelName = commentLabelName;
    
    [self.contentView addSubview:commentLabelName];
    
    
    NSMutableArray <NSLayoutConstraint*> *nameConstraints = [[NSMutableArray alloc] init];
    [nameConstraints addObject:[commentLabelName.topAnchor constraintEqualToAnchor:avatar.topAnchor]];
    [nameConstraints addObject:[commentLabelName.leadingAnchor constraintEqualToAnchor:avatar.trailingAnchor constant:5]];
    [nameConstraints addObject:[commentLabelName.trailingAnchor constraintEqualToAnchor:commentView.trailingAnchor]];
    for(NSLayoutConstraint *con in nameConstraints)
        con.active = YES;
    box.nameConstraints = nameConstraints;
    
    NSMutableArray <NSLayoutConstraint*> *nameConstraintsBig = [[NSMutableArray alloc] init];
    [nameConstraintsBig addObject:[commentLabelName.centerYAnchor constraintEqualToAnchor:avatar.centerYAnchor]];
    [nameConstraintsBig addObject:[commentLabelName.leadingAnchor constraintEqualToAnchor:avatar.trailingAnchor constant:20]];
    [nameConstraintsBig addObject:[commentLabelName.trailingAnchor constraintEqualToAnchor:commentLabelMessage.trailingAnchor]];
    box.nameConstraintsBig = nameConstraintsBig;
    
    // Name button
    buttonCommentName.translatesAutoresizingMaskIntoConstraints = NO;
    buttonCommentName.restorationIdentifier = @"commentNameButton";
    box.buttonName = buttonCommentName;
    [buttonCommentName addTarget:self action:@selector(commentNameTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:buttonCommentName];
    [buttonCommentName.topAnchor constraintEqualToAnchor:commentLabelName.topAnchor].active=YES;
    [buttonCommentName.bottomAnchor constraintEqualToAnchor:commentLabelName.bottomAnchor].active=YES;
    [buttonCommentName.leadingAnchor constraintEqualToAnchor:commentLabelName.leadingAnchor].active=YES;
    [buttonCommentName.trailingAnchor constraintEqualToAnchor:commentLabelName.trailingAnchor].active=YES;
    
    // Message label
    commentLabelMessage.translatesAutoresizingMaskIntoConstraints = NO;
    commentLabelMessage.restorationIdentifier = @"commentMessageLabel";
    commentLabelMessage.text = comment.userMessage;
    commentLabelMessage.numberOfLines = 0;
    //               commentLabelMessage.backgroundColor = [UIColor yellowColor];
    UIFont *oldFont = commentLabelMessage.font;
    commentLabelMessage.font = [UIFont fontWithName:oldFont.fontName size:oldFont.pointSize-5];
    [commentLabelMessage sizeToFit];
    commentLabelMessage.userInteractionEnabled = NO;
    box.commentLabelMessage = commentLabelMessage;
    
    [self.contentView addSubview:commentLabelMessage];
    
    box.messageConstraints = [[NSMutableArray alloc] init];
    [box.messageConstraints addObject:[commentLabelMessage.leadingAnchor constraintEqualToAnchor:avatar.trailingAnchor constant:5]];
    [box.messageConstraints addObject:[commentLabelMessage.topAnchor constraintEqualToAnchor:commentLabelName.bottomAnchor]];
    [box.messageConstraints addObject:[commentLabelMessage.trailingAnchor constraintEqualToAnchor:commentView.trailingAnchor]];
    [box.messageConstraints addObject:[commentLabelMessage.bottomAnchor constraintEqualToAnchor:avatar.bottomAnchor]];
    for (NSLayoutConstraint *con in box.messageConstraints)
        con.active = YES;
    
    box.messageConstraintsBig = [[NSMutableArray alloc] init];
    [box.messageConstraintsBig addObject:[commentLabelMessage.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:0]];
    [box.messageConstraintsBig addObject:[commentLabelMessage.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:60]];
    [box.messageConstraintsBig addObject:[commentLabelMessage.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-60]];
    
    
    
    // Message button
    buttonCommentMessage.translatesAutoresizingMaskIntoConstraints = NO;
    buttonCommentMessage.restorationIdentifier = @"commentMessageButton";
    [buttonCommentMessage addTarget:self action:@selector(commentMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
    buttonCommentMessage.tag = index;
    box.buttonMessage = buttonCommentMessage;
    
    [self.contentView addSubview:buttonCommentMessage];
    box.lastZPos = buttonCommentMessage.layer.zPosition;
    [buttonCommentMessage.topAnchor constraintEqualToAnchor:commentLabelMessage.topAnchor].active=YES;
    [buttonCommentMessage.bottomAnchor constraintEqualToAnchor:commentLabelMessage.bottomAnchor].active=YES;
    [buttonCommentMessage.leadingAnchor constraintEqualToAnchor:commentLabelMessage.leadingAnchor].active=YES;
    [buttonCommentMessage.trailingAnchor constraintEqualToAnchor:commentLabelMessage.trailingAnchor].active=YES;
    
    //commentView2 constrains
    [commentView2.topAnchor constraintEqualToAnchor:avatar.topAnchor constant:-8].active = YES;
    [commentView2.leadingAnchor constraintEqualToAnchor:avatar.leadingAnchor constant:-8].active = YES;
    [commentView2.bottomAnchor constraintEqualToAnchor:commentLabelMessage.bottomAnchor constant:8].active = YES;
    [commentView2.trailingAnchor constraintEqualToAnchor:commentLabelMessage.trailingAnchor constant:8].active = YES;
}

-(void)commentMessageTapped:(UIButton*)sender
{
    
    NSInteger index = sender.tag;
    CommentBox *box = self.commentBoxArr[index];

    CGFloat screenHeight = self.ScrollView.frame.size.height;
    CGPoint scrollOffset = self.ScrollView.contentOffset;
    box.messageConstraintsBig.firstObject.constant = screenHeight / 2 + scrollOffset.y - box.commentLabelMessage.frame.size.height /2;
    
    box.isBig = !box.isBig;
    
    __weak DescriptionViewController *weakSelf = self;
    if(box.isBig==YES)
    {
        box.commentView2.hidden = NO;
        [box takeElementsToTop];
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf commentBoxFirstConstraintsSwitchwithButton:sender];
            [weakSelf commentBoxSecondConstraintswitchwithButton:sender];
            [weakSelf.contentView layoutIfNeeded];
            box.commentView2.alpha=1;
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            [weakSelf commentBoxSecondConstraintswitchwithButton:sender];
            [weakSelf commentBoxFirstConstraintsSwitchwithButton:sender];
            [weakSelf.contentView layoutIfNeeded];
            box.commentView2.alpha=0;
        } completion:^(BOOL finished) {
            if(finished==YES)
                box.commentView2.hidden = YES;
        }];
    }

}

-(void)commentBoxFirstConstraintsSwitchwithButton:(UIButton*)sender
{
    NSInteger index = sender.tag;
    CommentBox *box = self.commentBoxArr[index];
    BOOL isActive = !box.isBig;
    
    for(NSLayoutConstraint *con in box.avatarConstraints)
        con.active = isActive;
    for(NSLayoutConstraint *con in box.nameConstraints)
        con.active = isActive;
    for(NSLayoutConstraint *con in box.messageConstraints)
        con.active = isActive;

}

-(void)commentBoxSecondConstraintswitchwithButton:(UIButton*)sender
{
    NSInteger index = sender.tag;
    CommentBox *box = self.commentBoxArr[index];
    BOOL isActive = box.isBig;

    for(NSLayoutConstraint *con in box.avatarConstraintsBig)
        con.active = isActive;
    for(NSLayoutConstraint *con in box.nameConstraintsBig)
        con.active = isActive;
    for(NSLayoutConstraint *con in box.messageConstraintsBig)
        con.active = isActive;
}


-(void)clearOldDynamicElements
{
    [self.backGreyView removeFromSuperview];
    
    for (ChangerBox *box in self.changerBoxArr)
    {
        [box.button removeFromSuperview];
        [box.label removeFromSuperview];
        [box.image removeFromSuperview];
    }
    [self.changerBoxArr removeAllObjects];
    
    [self.commentBoxArr makeObjectsPerformSelector:@selector(removeElementsFromSuperView)];
    [self.commentBoxArr removeAllObjects];
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
        self.changeButton.hidden = YES;
    }
    else
    {
        self.changeStatusArrow.hidden = NO;
        self.changeButton.hidden = NO;
    }
}



-(void)showNewStatuses
{
    UIView *backView = [[UIView alloc] init];
    backView.backgroundColor = [UIColor grayColor];
    backView.alpha = 0;
    backView.restorationIdentifier =@"dynamicItem showNewStatuses";
    backView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:backView];
    [backView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
    [backView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
    [backView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
    [backView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
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
                                 [self requestUsersAndComments];
                                 
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
