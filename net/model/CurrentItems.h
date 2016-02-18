//
//  CurrentItems.h
//  net
//
//  Created by Admin on 14.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Issue.h"
#import "CurrentItemsDelegate.h"

@interface CurrentItems : NSObject

@property(strong, nonatomic) User *user;
@property(strong, nonatomic) Issue *issue;
@property(strong, nonatomic) NSArray <NSDictionary*> *issueHistroy;
@property(strong, nonatomic) UIImage *userImage;
@property(strong, nonatomic) UIImage *issueImage;
@property(strong, nonatomic) NSArray<id<CurrentItemsDelegate>> *delegates;



+(instancetype)alloc __attribute__((unavailable("not available, use sharedItems")));
-(instancetype)init __attribute__((unavailable("not available, use sharedItems")));
-(instancetype)copy __attribute__((unavailable("not available, use sharedItems")));
+(instancetype)new __attribute__((unavailable("not available, use sharedItems")));

+(instancetype)sharedItems;

-(void)setUser:(User *)user withChangingImageViewBloc:(void(^)()) changinImageView;
-(void)setIssue:(Issue *)issue withChangingImageViewBloc:(void(^)()) changinImageView;

-(void)setUser:(User *)user;
-(void)setIssue:(Issue *)issue;


@end
