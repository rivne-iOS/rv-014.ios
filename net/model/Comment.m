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
                             andUsersDic:(NSDictionary <NSString*,id> *)userDic
                          andUIImageView:(UIImageView*)imageView
                      andImageDictionary:(NSMutableDictionary <NSString*, UIImage*> *) dictionary;
{
    if(self = [super init])
    {
        id<DataSorceProtocol> datasorce = [[NetworkDataSorce alloc] init];
        
        _userId = [commentDictionary objectForKey:@"USER_ID"];
        _userMessage = [commentDictionary objectForKey:@"COMMENT"];

        if(userDic == nil)
        {
            _userName = @"Deleted User";
            imageView.image = [UIImage imageNamed:@"deletedUser"];
        }
        else
        {
            _userName = [userDic objectForKey:@"NAME"];
            if (imageView!=nil)
            {
                NSString *imageName = [userDic objectForKey:@"AVATAR"];
                if ([imageName isEqual:[NSNull null]])
                    imageName = @"defaultUser";
                
                NSString *avatarStringName = [userDic objectForKey:@"AVATAR"];
                [dictionary setObject:(UIImage*)[NSNull null] forKey:avatarStringName];
                
                [datasorce requestImageWithName:imageName andHandler:^(UIImage *image, NSError *error) {
                    _userImage = image;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = image;
                        [dictionary setObject:image forKey:avatarStringName];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAvatarImages" object:nil userInfo:@{avatarStringName : image}];
                    });
                }];
            }
        }
        
    }
    
    return self;
    
}


@end
