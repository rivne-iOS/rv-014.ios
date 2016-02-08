//
//  IssueChangeStatus.m
//  net
//
//  Created by Admin on 28.01.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "IssueChangeStatus.h"


@interface IssueChangeStatus()

@property (strong,nonatomic)NSDictionary <NSString*, NSDictionary<NSString*, NSArray<NSString*> *> *> *changingDic;  // userRole : array of (ChangeStatusFrom : array of (ChangeStatusTo))

@end



@implementation IssueChangeStatus


-(NSDictionary <NSString*, NSDictionary<NSString*, NSArray<NSString*> *> *> *)changingDic
{
    if(_changingDic == nil)
    {
        NSArray *newForManager = @[@"APPROVED", @"CANCEL"];
        NSArray *toResolveForManager = @[@"RESOLVED"];
        NSDictionary *dicForManager = @{@"NEW" : newForManager, @"TO_RESOLVE" : toResolveForManager};

        NSArray *approvedForUser = @[@"TO_RESOLVE"];
        NSDictionary *dicForUser = @{@"APPROVED" : approvedForUser};
       
        _changingDic = @{@"USER" : dicForUser,  @"MANAGER": dicForManager};
    }
        
    return _changingDic;
}

-(NSArray <NSString*> *)newIssueStatusesForUser:(NSString*)user andCurretIssueStatus:(NSString*)status
{
    return [[self.changingDic objectForKey:user] objectForKey:status];
}


@end
