//
//  CurrentItems.m
//  net
//
//  Created by Admin on 14.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CurrentItems.h"
#import "NetworkDataSorce.h"


@interface CurrentItems()

@property(strong, nonatomic) id<DataSorceProtocol> dataSorce;

@end

@implementation CurrentItems

+(instancetype)sharedItems
{
    static CurrentItems *sharedItems_ = nil;
    static dispatch_once_t token =0;
    dispatch_once(&token, ^{
        sharedItems_ = [[super alloc] initSinleObject];
    });
    
    return sharedItems_;
}

-(instancetype)initSinleObject
{
    self = [super init];
    return self;
}


-(void)setUser:(User *)user withChangingImageViewBloc:(void(^)()) changinImageView
{
    self.user = user;
    
    //    NSString *av = self.user.avatarUrl;
    //    NSString * __strong * avatar = &av;
    NSString *unchangedName = self.user.avatarUrl;
    __block NSString *changedName = self.user.avatarUrl;
    
    [self.dataSorce requestImageWithName:self.user.avatarUrl andHandler:^(UIImage *image) {
        if ([unchangedName isEqualToString:changedName])
        {
            self.userImage = image;
            changinImageView();
            
        }
    } withErrorHandler:^(NSError *error) {
        // handle error
    }];
    
}

-(void)setIssue:(Issue *)issue withChangingImageViewBloc:(void(^)()) changinImageView
{
    self.issue = issue;
    
    //    NSString *av = self.user.avatarUrl;
    //    NSString * __strong * avatar = &av;
    NSString *unchangedName = self.issue.attachments;
    __block NSString *changedName = self.issue.attachments;
    
    [self.dataSorce requestImageWithName:self.issue.attachments andHandler:^(UIImage *image) {
        if ([unchangedName isEqualToString:changedName])
        {
            self.issueImage = image;
            changinImageView();
            
        }
    } withErrorHandler:^(NSError *error) {
        // handle error
    }];
    
}


-(id<DataSorceProtocol>)dataSorce
{
    if(_dataSorce==nil)
        _dataSorce = [[NetworkDataSorce alloc] init];
    return _dataSorce;
}

@end
