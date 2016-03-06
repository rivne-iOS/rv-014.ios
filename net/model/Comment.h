//
//  Comment.h
//  net
//
//  Created by Admin on 18.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "User.h"

@interface Comment : NSObject

@property(strong, nonatomic) NSNumber *userId;
@property(strong, nonatomic) NSString *userName;
@property(strong, nonatomic) UIImage *userImage;
@property(strong, nonatomic) NSString *userMessage;


-(instancetype)initWithCommentDictionary:(NSDictionary <NSString*,id> *)commentDictionary
                                 andUser:(User *)user
                          andUIImageView:(UIImageView*)imageView
                      andImageDictionary:(NSMutableDictionary <NSString*, UIImage*> *) dictionary;


@end
