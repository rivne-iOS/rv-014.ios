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
        NSArray *newForManager = @[@"APPROVED", @"CANCELED"];
        NSArray *toResolveForManager = @[@"RESOLVED"];
        NSDictionary *dicForManager = @{@"NEW" : newForManager, @"TO_RESOLVE" : toResolveForManager};

        NSArray *approvedForUser = @[@"TO_RESOLVE"];
        NSDictionary *dicForUser = @{@"APPROVED" : approvedForUser};
       
        _changingDic = @{@"USER" : dicForUser,  @"MANAGER": dicForManager, @"ADMIN" : dicForManager};
    }
        
    return _changingDic;
}

-(NSDictionary <NSString*, NSDictionary<NSString*, NSArray<NSString*> *> *> *)changingDicLabel
{
    if(_changingDic == nil)
    {
        NSArray *newForManager = @[@"Approve Issue", @"Disaprove issue"];
        NSArray *toResolveForManager = @[@"Conmirm resolving issue"];
        NSDictionary *dicForManager = @{@"NEW" : newForManager, @"TO_RESOLVE" : toResolveForManager};
        
        NSArray *approvedForUser = @[@"Mark as resolved"];
        NSDictionary *dicForUser = @{@"APPROVED" : approvedForUser};
        
        _changingDic = @{@"USER" : dicForUser,  @"MANAGER": dicForManager, @"ADMIN" : dicForManager};
    }
    
    return _changingDic;
}

-(NSArray <NSString*> *)newIssueStatusesForUser:(NSString*)user andCurretIssueStatus:(NSString*)status
{
    return [[self.changingDic objectForKey:user] objectForKey:status];
}

-(NSArray <NSString*> *)newIssueLabelStatusesForUser:(NSString*)user andCurretIssueStatus:(NSString*)status
{
    return [[self.changingDicLabel objectForKey:user] objectForKey:status];
}

-(NSString*)labelTextForNewStatus:(NSString*)newStatus
{
    if([newStatus isEqualToString:@"APPROVED"])
        return @"Approve Issue";
    else if([newStatus isEqualToString:@"CANCELED"])
        return @"Disaprove issue";
    else if([newStatus isEqualToString:@"TO_RESOLVE"])
        return @"Mark issue as resolved";
    else if([newStatus isEqualToString:@"RESOLVED"])
        return @"Conmirm resolving issue";
    else return nil;
}

-(NSString*)labelAdditionalTextForNewStatus:(NSString*)newStatus
{
    if([newStatus isEqualToString:@"TO_RESOLVE"])
        return @"(needs manager confirmation)";
    else return nil;
}



@end
