//
//  Comment.h
//  net
//
//  Created by Admin on 18.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Comment : NSObject

@property(strong, nonatomic) NSString *userName;
@property(strong, nonatomic) UIImage *userImage;
@property(strong, nonatomic) NSString *userMessage;


-(void)initWithCommentDictionary:(NSDictionary <NSString*,NSString*> *)commentDictionary
           andAllUsersDictionaries:(NSArray <NSDictionary <NSString*,NSString*> *> *)usersDictionaries;

@end
