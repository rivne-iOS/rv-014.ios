//
//  IssueChangeStatus.h
//  net
//
//  Created by Admin on 28.01.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IssueChangeStatus : NSObject

-(NSArray <NSString*> *)newIssueStatusesForUser:(NSString*)user andCurretIssueStatus:(NSString*)status;
-(NSArray <NSString*> *)newIssueLabelStatusesForUser:(NSString*)user andCurretIssueStatus:(NSString*)status;
-(NSString*)labelTextForNewStatus:(NSString*)newStatus;

@end
