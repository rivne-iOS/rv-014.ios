//
//  IssueCategories.m
//  net
//
//  Created by Admin on 18.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "IssueCategories.h"
#import "NetworkDataSorce.h"

static IssueCategories *standartCategories_ = nil;

@implementation IssueCategories

-(instancetype)initSingleObject
{
    if(self=[super init])
    {
        id<DataSorceProtocol> dataSorce = [[NetworkDataSorce alloc] init];
        [dataSorce requestCategories:^(NSArray<IssueCategory *> *issueCategories) {
            _categories = issueCategories;
        } withErrorHandler:^(NSError *error) {
            // error
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

@end
