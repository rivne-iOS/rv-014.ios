//
//  Comment.m
//  net
//
//  Created by Admin on 18.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "Comment.h"
#import "NetworkDataSorce.h"

@implementation Comment

//{
//    "USER_ID": 1,
//    "COMMENT": "Text of comment",
//    "DATE": "01/01/2016"
//}


-(instancetype)initWithCommentDictionary:(NSDictionary <NSString*,id> *)commentDictionary
                 andAllUsersDictionaries:(NSArray <NSDictionary <NSString*,NSString*> *> *)usersDictionaries
{
    self = [self initWithCommentDictionary:commentDictionary andAllUsersDictionaries:usersDictionaries andUIImageView:nil];
    return self;
}


-(instancetype)initWithCommentDictionary:(NSDictionary <NSString*,id> *)commentDictionary
                 andAllUsersDictionaries:(NSArray <NSDictionary <NSString*,NSString*> *> *)usersDictionaries
                          andUIImageView:(UIImageView*)imageView
{
    if(self = [super init])
    {
        id<DataSorceProtocol> datasorce = [[NetworkDataSorce alloc] init];
        
        NSDictionary <NSString*,NSString*> *userDic = nil;
        
        for (NSDictionary <NSString*,NSString*> *tUserDic in usersDictionaries)
        {
            if([tUserDic objectForKey:@"ID"].intValue == [[commentDictionary objectForKey:@"USER_ID"] intValue])
            {
                userDic = tUserDic;
                break;
            }
        }
        // todo: chek userr. create new request for all users
        // then create deleted user if needed
        
        _userId = [commentDictionary objectForKey:@"USER_ID"];
        _userName = [userDic objectForKey:@"NAME"];
        _userMessage = [commentDictionary objectForKey:@"COMMENT"];
        
        NSString *imageName = [userDic objectForKey:@"AVATAR"];
        if ([imageName isEqual:[NSNull null]])
            imageName = @"defaultUser";
        
        [datasorce requestImageWithName:imageName andHandler:^(UIImage *image, NSError *error) {
            _userImage = image;
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
            });
        }];
    }
    
    return self;
    
}


@end
