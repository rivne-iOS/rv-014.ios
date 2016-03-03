//
//  CommentBox.h
//  net
//
//  Created by Admin on 22.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AvatarView.h"

@interface CommentBox : NSObject


@property(strong, nonatomic)NSNumber *userID;
@property(nonatomic)NSNumber *issueID;

@property(strong, nonatomic) UIView *commentView;
@property(strong, nonatomic) UILabel *commentLabelName;
@property(strong, nonatomic) UILabel *commentLabelMessage;

@property(strong, nonatomic) NSString *avatarStringName;
@property(strong, nonatomic) AvatarView *avatar;

@property(strong, nonatomic) UIButton *buttonName;
@property(strong, nonatomic) UIButton *buttonMessage;
@property(strong, nonatomic) UIButton *buttonImage;

@property(strong, nonatomic) NSLayoutConstraint *commentMessageHeightConstraint;

@property(nonatomic)BOOL isBig;
@property(nonatomic)BOOL isNeedResize;
@property(nonatomic)CGFloat messageBigHeight;
@property(nonatomic)CGFloat messageSmallHeight;

@property(nonatomic)CGFloat firstZPos;
@property(nonatomic)CGFloat lastZPos;

-(instancetype)initWithView:(UIView*)view
                andUserName:(UILabel*)name
                andButtonName:(UIButton*)buttonName
             andUserMessage:(UILabel*)message
             andButtonMessage:(UIButton*)buttonMessage
                  andAvatar:(AvatarView*) avatar
                  andButtonAvatar:(UIButton*) buttonAvatar;

-(void)removeElementsFromSuperView;


-(void)takeElementsToTop;
@end
