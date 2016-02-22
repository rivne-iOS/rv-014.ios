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

@property(strong, nonatomic) UIView *commentView;
@property(strong, nonatomic) UILabel *commentLabelName;
@property(strong, nonatomic) UILabel *commentLabelMessage;
@property(strong, nonatomic) AvatarView *avatar;

@property(strong, nonatomic) UIButton *buttonName;
@property(strong, nonatomic) UIButton *buttonMessage;
@property(strong, nonatomic) UIButton *buttonImage;

@property(strong, nonatomic) NSMutableArray <NSLayoutConstraint*> *messageConstraints;
@property(strong, nonatomic) NSMutableArray <NSLayoutConstraint*> *messageConstraintsBig;

@property(strong, nonatomic) NSMutableArray <NSLayoutConstraint*> *nameConstraints;
@property(strong, nonatomic) NSMutableArray <NSLayoutConstraint*> *nameConstraintsBig;

@property(strong, nonatomic) NSMutableArray <NSLayoutConstraint*> *avatarConstraints;
@property(strong, nonatomic) NSMutableArray <NSLayoutConstraint*> *avatarConstraintsBig;

@property(nonatomic)BOOL isBig;

-(instancetype)initWithView:(UIView*)view
                andUserName:(UILabel*)name
                andButtonName:(UIButton*)buttonName
             andUserMessage:(UILabel*)message
             andButtonMessage:(UIButton*)buttonMessage
                  andAvatar:(AvatarView*) avatar
                  andButtonAvatar:(UIButton*) buttonAvatar;

-(void)removeElementsFromSuperView;
@end
