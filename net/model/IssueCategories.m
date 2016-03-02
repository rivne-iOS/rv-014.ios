//
//  IssueCategories.m
//  net
//
//  Created by Admin on 18.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "IssueCategories.h"
#import "NetworkDataSorce.h"
#import "CurrentItems.h"

static IssueCategories *standartCategories_ = nil;

@implementation IssueCategories

-(instancetype)initSingleObject
{
    if(self=[super init])
    {
        id<DataSorceProtocol> dataSorce = [[NetworkDataSorce alloc] init];
        [dataSorce requestCategories:^(NSArray<IssueCategory *> *issueCategories, NSError *error) {
            _categories = issueCategories;
        }];
    }
    return self;
}

+(void)object
{
    static dispatch_once_t token =0;
    dispatch_once(&token, ^{
        standartCategories_ = [[super alloc] initSingleObject];
    });
}

+(void)earlyPreparing
{
    [IssueCategories object];
}

+(instancetype)standartCategories
{
    [IssueCategories object];
    return standartCategories_;
}

-(UIImage*)imageForCurrentCategory
{
    NSInteger intId = [CurrentItems sharedItems].issue.categoryId.intValue;
    for (NSInteger a=0; a<self.categories.count; ++a)
    {
        if(self.categories[a].categoryId.intValue == intId)
        {
            return self.categories[a].image;
        }
    }
    return nil;
}

@end
