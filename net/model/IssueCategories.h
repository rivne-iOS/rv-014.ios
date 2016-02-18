//
//  IssueCategories.h
//  net
//
//  Created by Admin on 18.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IssueCategory.h"

@interface IssueCategories : NSObject

@property(strong, nonatomic) NSArray <IssueCategory*> *categories;

+(instancetype)alloc __attribute__((unavailable("not available, use categories")));
-(instancetype)init __attribute__((unavailable("not available, use categories")));
-(instancetype)copy __attribute__((unavailable("not available, use categories")));
+(instancetype)new __attribute__((unavailable("not available, use categories")));

+(instancetype)standartCategories;
+(void)earlyPreparing;
@end
