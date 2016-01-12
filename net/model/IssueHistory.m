//
//  BPPointHistory.m
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import "IssueHistory.h"

@implementation IssueHistory


-(NSString*)description
{
    return [NSString stringWithFormat:@"UserId - %d, made an action - %@, at:", (unsigned int)self.userId, self.action, [self.date description]];
}


@end
