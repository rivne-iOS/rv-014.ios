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

-(id<DataSorceProtocol>)dataSorce
{
    if(_dataSorce==nil)
        _dataSorce = [[NetworkDataSorce alloc] init];
    return _dataSorce;
}


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
    if(self = [super init])
    {
        _userImageDelegates = [[NSMutableArray alloc] init];
        _issueImageDelegates = [[NSMutableArray alloc] init];
    }
    return self;
}


-(void)setUser:(User *)user
{
    _user = user;
    NSString *unchangedName = self.user.avatar;
    [self.dataSorce requestImageWithName:self.user.avatar andHandler:^(UIImage *image) {
        if ([unchangedName isEqualToString:self.user.avatar])
        {
            self.userImage = image;
            [self.userImageDelegates makeObjectsPerformSelector:@selector(userImageDidLoad)];
        }
    } withErrorHandler:^(NSError *error) {
        // handle error
    }];

    
}

-(void)setUser:(User *)user withChangingImageViewBloc:(void(^)()) changinImageView
{
    self.user = user;
    
    NSString *unchangedName = self.user.avatar;
    [self.dataSorce requestImageWithName:self.user.avatar andHandler:^(UIImage *image) {
        if ([unchangedName isEqualToString:self.user.avatar])
        {
            self.userImage = image;
            changinImageView();
            
        }
    } withErrorHandler:^(NSError *error) {
        // handle error
    }];
    
}

-(void)setIssue:(Issue *)issue
{
    _issue = issue;
    NSString *unchangedName = self.issue.attachments;
    [self.dataSorce requestImageWithName:self.issue.attachments andHandler:^(UIImage *image) {
        if ([unchangedName isEqualToString:self.issue.attachments])
        {
            self.issueImage = image;
            NSLog(@"image downloaded and seted to current, fend issueImageDidLoad");
            NSLog(@"issueImageDelegates: %@", self.issueImageDelegates);
            [self.issueImageDelegates makeObjectsPerformSelector:@selector(issueImageDidLoad)];
        }
    } withErrorHandler:^(NSError *error) {
        // handle error
    }];
}

-(void)setIssue:(Issue *)issue withChangingImageViewBloc:(void(^)()) changinImageView
{
    self.issue = issue;
    
    NSString *unchangedName = self.issue.attachments;
    [self.dataSorce requestImageWithName:self.issue.attachments andHandler:^(UIImage *image) {
        if ([unchangedName isEqualToString:self.issue.attachments])
        {
            self.issueImage = image;
            changinImageView();
            
        }
    } withErrorHandler:^(NSError *error) {
        // handle error
    }];
    
}





@end
