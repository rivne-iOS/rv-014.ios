//
//  BPPoint.h
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IssueHistory.h"


typedef enum : NSUInteger {
    APPROVED,
    TO_RESOLVE,
    RESOLVED,
} status;


@interface Issue : NSObject

@property(nonatomic, readonly)NSArray *stringStatus;

@property(nonatomic)NSUInteger pointId;
@property(strong, nonatomic)NSString *pDescription;
@property(strong, nonatomic)NSString *mapInfo;
@property(strong, nonatomic)NSString *name;
@property(strong, nonatomic)NSArray *pointHistory; // of IssueHistory



+(NSArray*)BPPointStringStatuses;

@end
