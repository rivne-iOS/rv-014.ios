//
//  CommentBox.m
//  net
//
//  Created by Admin on 22.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CommentBox.h"

@implementation CommentBox

-(instancetype)initWithView:(UIView*)view
                   andView2:(UIView*)view2
                andUserName:(UILabel*)name
              andButtonName:(UIButton*)buttonName
             andUserMessage:(UILabel*)message
           andButtonMessage:(UIButton*)buttonMessage
                  andAvatar:(AvatarView*) avatar
            andButtonAvatar:(UIButton*) buttonAvatar;
{
    if(self = [super init])
    {
        _avatar = avatar;
        _buttonImage = buttonAvatar;
        _commentLabelMessage = message;
        _buttonMessage = buttonMessage;
        _commentLabelName = name;
        _buttonName = buttonName;
        _commentView = view;
        _commentView2 = view2;
    }
    return self;
}

-(void)removeElementsFromSuperView
{
    [self.avatar removeFromSuperview];
    [self.buttonImage removeFromSuperview];
    [self.commentLabelName removeFromSuperview];
    [self.buttonName removeFromSuperview];
    [self.commentLabelMessage removeFromSuperview];
    [self.buttonMessage removeFromSuperview];
    [self.commentView removeFromSuperview];
    [self.commentView2 removeFromSuperview];
}

-(void)takeElementsToTop
{
    UIView *superView = self.commentView2.superview;
    [superView bringSubviewToFront:self.commentView2];
    [superView bringSubviewToFront:self.avatar];
    [superView bringSubviewToFront:self.buttonImage];
    [superView bringSubviewToFront:self.commentLabelName];
    [superView bringSubviewToFront:self.buttonName];
    [superView bringSubviewToFront:self.commentLabelMessage];
    [superView bringSubviewToFront:self.buttonMessage];
}



@end

