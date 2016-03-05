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
#import "ProfileViewController.h"



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

@property (strong,nonatomic) NSMutableDictionary <NSString*, UIImage*> *avatarNamesAndImagesDic;
// @property (strong,nonatomic) NSMutableDictionary <NSString*, UIImageView*> *avatarNamesAndImageViewsDic;

@property(nonatomic) CGFloat avatarSize;
@property(nonatomic) CGFloat contentStaticHeight;
@property(nonatomic) CGFloat contentDynamicHeight;


@property(strong,nonatomic) UITextView *addCommentDynamicTextView;
@property(strong, nonatomic) UIView *addCommentDynamicGreyView;
@property(strong, nonatomic) UIButton *addCommentDynamicButton;


@property(strong, nonatomic)NSNumber *callingSegueToProfileUserId;
@end

@implementation DescriptionViewController



#pragma mark - Lasy instantiation


-(NSMutableDictionary <NSString*, UIImage*> *)avatarNamesAndImagesDic
{
    if(_avatarNamesAndImagesDic==nil)
        _avatarNamesAndImagesDic = [[NSMutableDictionary alloc] init];
    return _avatarNamesAndImagesDic;
}

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
    UIFont *newFont = [UIFont fontWithName:@"ComicSansMS-Italic" size:25];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                    NSFontAttributeName : newFont};
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.avatarSize = self.contentView.frame.size.width / 10;
    
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    CurrentItems *cItems = [CurrentItems sharedItems];
    self.title = cItems.appTitle;
    [self setDataToView];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAvatarImages:)
                                                 name:@"updateAvatarImages" object:nil];
    
}

-(void)updateAvatarImages:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    for (CommentBox *box in self.commentBoxArr)
    {
        if ([box.avatarStringName isEqualToString:userInfo.allKeys.firstObject])
        {
            box.avatar.image = [userInfo objectForKey:box.avatarStringName];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clearOldDynamicElements];
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
    UITextView *addCommentTextView = [[UITextView alloc] init];
    addCommentTextView.translatesAutoresizingMaskIntoConstraints = NO;
    addCommentTextView.backgroundColor = [UIColor whiteColor];

    self.addCommentDynamicTextView = addCommentTextView;
    [self.view addSubview:addCommentTextView];
    [addCommentTextView becomeFirstResponder];
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
    if (self.addCommentDynamicTextView == nil)
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
    
    CGFloat textFieldHeight = 30;
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGSize buttonTittleSize = [buttonTitle sizeWithAttributes:@{NSFontAttributeName : addCommentButton.titleLabel.font}];
    
    self.addCommentDynamicTextView.layer.cornerRadius = 4;
    
    [self scrollBottomConstraint].constant = keyboardHeight + textFieldHeight - tabBarHeight;
    [self.view layoutIfNeeded];
    
    [self.view insertSubview:grayView belowSubview:self.addCommentDynamicTextView];
    [self.view addSubview:addCommentButton];
    [addCommentButton sizeToFit];
    
    [grayView.topAnchor constraintEqualToAnchor:self.ScrollView.bottomAnchor].active = YES;
    [grayView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [grayView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [grayView.heightAnchor constraintEqualToConstant:textFieldHeight].active = YES;
    
    [self.addCommentDynamicTextView.topAnchor constraintEqualToAnchor:grayView.topAnchor constant:2].active = YES;
    [self.addCommentDynamicTextView.leadingAnchor constraintEqualToAnchor:grayView.leadingAnchor constant:8].active = YES;
    [self.addCommentDynamicTextView.trailingAnchor constraintEqualToAnchor:addCommentButton.leadingAnchor constant:-8].active = YES;
    [self.addCommentDynamicTextView.bottomAnchor constraintEqualToAnchor:grayView.bottomAnchor constant:-2].active = YES;
    
    [addCommentButton.trailingAnchor constraintEqualToAnchor:grayView.trailingAnchor constant:-8].active = YES;
    [addCommentButton.centerYAnchor constraintEqualToAnchor:self.addCommentDynamicTextView.centerYAnchor].active = YES;
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
    NSString *message = self.addCommentDynamicTextView.text;
    [self.addCommentDynamicTextView resignFirstResponder];
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
    [self.dataSorce requestAllUsers:^(NSArray<NSDictionary<NSString *,NSString *> *> *userDictionaries, NSError *error) {
        [weakSelf sendMessage:message andAddnewCommentsBlockWithAllUserDictionaries:userDictionaries];
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
               NSDictionary <NSString*,id> *userDic = [self userDicFromAllUsers:allUserDictionaries andUserID:[commentDic objectForKey:@"USER_ID"]];
               [weakSelf addOneComment:commentDic withIndex:index usersDic:userDic];
           }
           NSLog(@"weakSelf.viewBetweenCommentAndChare %@",weakSelf.viewBetweenCommentAndChare);
           weakSelf.contentViewHeightConstraint.constant = weakSelf.contentDynamicHeight + weakSelf.contentStaticHeight;
           [weakSelf.view layoutIfNeeded];
            
            
            CGFloat yOffset = self.contentView.frame.size.height - self.ScrollView.frame.size.height;
            if (yOffset>0)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    self.ScrollView.contentOffset = CGPointMake(0, yOffset);
                }];
            }
        });
    }];
    
}



#pragma mark - Dynamic elements

-(void)requestUsersAndComments
{
    __weak DescriptionViewController *weakSelf = self;
    [self.dataSorce requestAllUsers:^(NSArray<NSDictionary<NSString *,NSString *> *> *userDictionaries, NSError *error) {
        [weakSelf commentBlockWithAllUserDictionaries:userDictionaries];
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
           weakSelf.contentDynamicHeight = 0;
           if(commentDics==nil || error != nil || [commentDics isKindOfClass: [NSDictionary class]])
               return;
           weakSelf.contentView.restorationIdentifier = @"contentView";
           for (NSInteger index=0; index<commentDics.count; ++index)
           {
               
               NSDictionary<NSString *,id> *commentDic = commentDics[index];
               NSDictionary <NSString*,id> *userDic = [self userDicFromAllUsers:allUserDictionaries andUserID:[commentDic objectForKey:@"USER_ID"]];
               [weakSelf addOneComment:commentDic withIndex:index usersDic:userDic];
           }
           NSLog(@"weakSelf.viewBetweenCommentAndChare %@",weakSelf.viewBetweenCommentAndChare);
           weakSelf.contentViewHeightConstraint.constant = weakSelf.contentDynamicHeight + weakSelf.contentStaticHeight;
           [weakSelf.view layoutIfNeeded];
       });
    }];
    
}

-(NSDictionary <NSString*,id> *)userDicFromAllUsers:(NSArray <NSDictionary <NSString*,id> *> *)allUsersDictionaries andUserID:(NSNumber*)userId
{
    NSDictionary <NSString*,NSString*> *userDic = nil;
    for (NSDictionary <NSString*,NSString*> *tUserDic in allUsersDictionaries)
    {
        if([tUserDic objectForKey:@"ID"].intValue == [userId intValue])
        {
            userDic = tUserDic;
            break;
        }
    }
    return userDic;
}



-(void)addOneComment:(NSDictionary <NSString*, id> *)commentDic withIndex:(NSInteger)index usersDic:(NSDictionary <NSString*,id> *)userDic
{
    CommentBox *box = [[CommentBox alloc] init];
    UIView *commentView = [[UIView alloc] init];
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
    self.contentDynamicHeight += self.avatarSize+10;
    box.firstZPos = commentView.layer.zPosition;

    //Avatar
    avatar.translatesAutoresizingMaskIntoConstraints = NO;
    avatar.restorationIdentifier = @"AvatarImageView";
    box.avatar = avatar;
    box.avatarStringName = [userDic objectForKey:@"AVATAR"];
    [self.contentView addSubview:avatar];
    
    //comment init with image View
    NSString *avatarStringName = [userDic objectForKey:@"AVATAR"];
    UIImage *avatarImage = [self.avatarNamesAndImagesDic objectForKey:avatarStringName];
    Comment *comment = nil;
    if(avatarImage!=nil)
    {
        if(![avatarImage isEqual:[NSNull null]])
        {
            avatar.image = avatarImage;   
        }
        comment = [[Comment alloc] initWithCommentDictionary:commentDic andUsersDic:userDic  andUIImageView:nil andImageDictionary:nil];
    }
    else
    {
        comment = [[Comment alloc] initWithCommentDictionary:commentDic
                                                 andUsersDic:userDic
                                              andUIImageView:(UIImageView*)avatar
                                          andImageDictionary:self.avatarNamesAndImagesDic];
    }

    // id
    box.userID = comment.userId;
    box.issueID = [CurrentItems sharedItems].issue.issueId;

    //button Avatar
    buttonAvatar.translatesAutoresizingMaskIntoConstraints = NO;
    buttonAvatar.restorationIdentifier = @"buttonAvatarImageView";
    buttonAvatar.tag = index;
    box.buttonImage = buttonAvatar;
    [buttonAvatar addTarget:self action:@selector(commentAvatarTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:buttonAvatar];
    
    // Name label
    commentLabelName.translatesAutoresizingMaskIntoConstraints = NO;
    commentLabelName.restorationIdentifier = @"commentNameLabel";
    commentLabelName.text = comment.userName;
    box.commentLabelName = commentLabelName;
    [self.contentView addSubview:commentLabelName];

    // Name button
    buttonCommentName.translatesAutoresizingMaskIntoConstraints = NO;
    buttonCommentName.restorationIdentifier = @"commentNameButton";
    buttonCommentName.tag = index;
    box.buttonName = buttonCommentName;
    [buttonCommentName addTarget:self action:@selector(commentNameTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:buttonCommentName];

    // Message label
    commentLabelMessage.translatesAutoresizingMaskIntoConstraints = NO;
    commentLabelMessage.restorationIdentifier = @"commentMessageLabel";
    
    NSMutableParagraphStyle *paragraph= [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentJustified;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName : paragraph,
                                 NSBaselineOffsetAttributeName : [NSNumber numberWithFloat:0]};
    commentLabelMessage.attributedText = [[NSAttributedString alloc] initWithString:comment.userMessage
                                                                         attributes:attributes];
    commentLabelMessage.numberOfLines = 0;
    UIFont *oldFont = commentLabelMessage.font;
    commentLabelMessage.font = [UIFont fontWithName:oldFont.fontName size:oldFont.pointSize-5];
    [commentLabelMessage sizeToFit];
    commentLabelMessage.userInteractionEnabled = NO;
    box.commentLabelMessage = commentLabelMessage;
    [self.contentView addSubview:commentLabelMessage];

    // Message button
    buttonCommentMessage.translatesAutoresizingMaskIntoConstraints = NO;
    buttonCommentMessage.restorationIdentifier = @"commentMessageButton";
    [buttonCommentMessage addTarget:self action:@selector(commentMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
    buttonCommentMessage.tag = index;
    box.buttonMessage = buttonCommentMessage;
    
    [self.contentView addSubview:buttonCommentMessage];
    box.lastZPos = buttonCommentMessage.layer.zPosition;

    
    CGFloat avatarLeadingOffset = 4;
    CGFloat avatarAndNameTopOffset = 5;
    CGFloat nameAndMessageLeadingOffset = 4;
    CGFloat messageTrailingOffset = 4;
    CGFloat messageBottomOffset = 5;
    CGFloat commentViewOffset = 8;
    CGFloat messageAndNameLabelWidth = self.contentView.frame.size.width
                                        - commentViewOffset*2
                                        - avatarLeadingOffset
                                        - self.avatarSize
                                        - nameAndMessageLeadingOffset
                                        - messageTrailingOffset;
    
    
    
    CGRect nameLabelRect = [commentLabelName.text boundingRectWithSize:CGSizeMake(messageAndNameLabelWidth, MAXFLOAT)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:@{NSFontAttributeName : commentLabelName.font}
                                                                context:nil];
    CGFloat nameLabelHeight = nameLabelRect.size.height;
    
    
    CGRect messageLabelRect =  [commentLabelMessage.text boundingRectWithSize:CGSizeMake(messageAndNameLabelWidth, MAXFLOAT)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName : commentLabelMessage.font}
                                                                      context:nil];
    CGFloat messageLabelHeight = messageLabelRect.size.height;
    
    box.messageSmallHeight = self.avatarSize - nameLabelHeight;
    if (messageLabelHeight > self.avatarSize - nameLabelHeight)
    {
        box.isNeedResize = YES;
        box.isBig = NO;
        box.messageBigHeight = messageLabelHeight;
    }
    else
    {
        box.isNeedResize = NO;
    }
    
    [commentView.topAnchor constraintEqualToAnchor:self.viewToConnectDynamicItems.bottomAnchor].active = YES;
    self.viewToConnectDynamicItems = commentView;
    [commentView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:commentViewOffset].active = YES;
    [commentView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-commentViewOffset].active = YES;
    [commentView.bottomAnchor constraintEqualToAnchor:commentLabelMessage.bottomAnchor constant:messageBottomOffset].active = YES;
    
    [avatar.widthAnchor constraintEqualToConstant:self.avatarSize].active = YES;
    [avatar.heightAnchor constraintEqualToConstant:self.avatarSize].active = YES;
    [avatar.leadingAnchor constraintEqualToAnchor:commentView.leadingAnchor].active = YES;
    [avatar.topAnchor constraintEqualToAnchor:commentView.topAnchor constant:avatarAndNameTopOffset].active = YES;
    
    [buttonAvatar.topAnchor constraintEqualToAnchor:avatar.topAnchor].active=YES;
    [buttonAvatar.bottomAnchor constraintEqualToAnchor:avatar.bottomAnchor].active=YES;
    [buttonAvatar.leadingAnchor constraintEqualToAnchor:avatar.leadingAnchor].active=YES;
    [buttonAvatar.trailingAnchor constraintEqualToAnchor:avatar.trailingAnchor].active=YES;
    
    [commentLabelName.topAnchor constraintEqualToAnchor:avatar.topAnchor].active=YES;
    [commentLabelName.leadingAnchor constraintEqualToAnchor:avatar.trailingAnchor constant:nameAndMessageLeadingOffset].active = YES;
    [commentLabelName.trailingAnchor constraintEqualToAnchor:commentView.trailingAnchor].active = YES;
    [commentLabelName.heightAnchor constraintEqualToConstant:nameLabelHeight].active = YES;
    
    [buttonCommentName.topAnchor constraintEqualToAnchor:commentLabelName.topAnchor].active=YES;
    [buttonCommentName.leadingAnchor constraintEqualToAnchor:commentLabelName.leadingAnchor].active=YES;
    [buttonCommentName.trailingAnchor constraintEqualToAnchor:commentLabelName.trailingAnchor].active=YES;
    
    
    [commentLabelMessage.leadingAnchor constraintEqualToAnchor:avatar.trailingAnchor constant:nameAndMessageLeadingOffset].active = YES;
    [commentLabelMessage.topAnchor constraintEqualToAnchor:commentLabelName.bottomAnchor].active = YES;
    [commentLabelMessage.widthAnchor constraintEqualToConstant:messageAndNameLabelWidth].active=YES;
    box.commentMessageHeightConstraint = [commentLabelMessage.heightAnchor constraintEqualToConstant:self.avatarSize - nameLabelHeight];
    box.commentMessageHeightConstraint.active = YES;
    
    [buttonCommentMessage.topAnchor constraintEqualToAnchor:commentLabelMessage.topAnchor].active=YES;
    [buttonCommentMessage.bottomAnchor constraintEqualToAnchor:commentLabelMessage.bottomAnchor].active=YES;
    [buttonCommentMessage.leadingAnchor constraintEqualToAnchor:commentLabelMessage.leadingAnchor].active=YES;
    [buttonCommentMessage.trailingAnchor constraintEqualToAnchor:commentLabelMessage.trailingAnchor].active=YES;
    
}

-(void)commentAvatarTapped:(UIButton*)sender
{
    [self callSegueToProfileWitTappedButton:sender];
}

-(void)commentNameTapped:(UIButton*)sender
{
    [self callSegueToProfileWitTappedButton:sender];
}

-(void)callSegueToProfileWitTappedButton:(UIButton*) sender
{
    NSInteger index = sender.tag;
    CommentBox *box = self.commentBoxArr[index];
    self.callingSegueToProfileUserId = box.userID;
    [self performSegueWithIdentifier:@"fromDescriptionToProfile" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"fromDescriptionToProfile"]) {
        if([segue.destinationViewController isKindOfClass:[ProfileViewController class]])
        {
            ProfileViewController *profileViewController = (ProfileViewController*)segue.destinationViewController;
            profileViewController.userID = self.callingSegueToProfileUserId.integerValue;
            profileViewController.isLogged = ([CurrentItems sharedItems].user != nil);
            profileViewController.dataSorce = self.dataSorce;
        }
    }
}


-(void)commentMessageTapped:(UIButton*)sender
{
    NSInteger index = sender.tag;
    CommentBox *box = self.commentBoxArr[index];

    
    if (box.isNeedResize==NO)
        return;
    
   box.isBig = !box.isBig;
    
    __weak DescriptionViewController *weakSelf = self;
    if(box.isBig==YES)
    {
        CGFloat newContentViewHeightConstraint = self.contentViewHeightConstraint.constant - box.messageSmallHeight + box.messageBigHeight;
        
        [UIView animateWithDuration:0.2 animations:^{
            box.commentMessageHeightConstraint.constant = box.messageBigHeight;
            weakSelf.contentViewHeightConstraint.constant = newContentViewHeightConstraint;
            [weakSelf.contentView layoutIfNeeded];
        }];
    }
    else
    {
        CGFloat newContentViewHeightConstraint = self.contentViewHeightConstraint.constant - box.messageBigHeight + box.messageSmallHeight;
        [UIView animateWithDuration:0.2 animations:^{
            box.commentMessageHeightConstraint.constant = box.messageSmallHeight;
            weakSelf.contentViewHeightConstraint.constant = newContentViewHeightConstraint;
            [weakSelf.contentView layoutIfNeeded];
        }];
    }

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
    [self.avatarNamesAndImagesDic removeAllObjects];
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
                     andViewControllerHandler:^(NSString *stringAnswer, Issue *issue, NSError *error) {
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
                     }];
    
}
    
                             
                             
    
                         

@end
