//
//  BPPoint.m
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import "Issue.h"

@interface Issue()

-(NSString*)pointHistoryToString;

@end


@implementation Issue

+(NSArray*)BPPointStringStatuses
{
    return @[@"APPREVED", @"TO_RESOLVE", @"RESOLVED"];
}


//-(instancetype)init
//{
//    if (self=[super init]) {
//        _stringStatus = [[NSArray alloc] initWithObjects:@"APPREVED", @"TO_RESOLVE", @"RESOLVED", nil];
//    }
//    return self;
//}


-(NSString*)description
{
    return [NSString stringWithFormat:@"This is a point with name - %@, mapInfo - %@, and such history:\n%@", self.name, self.mapInfo, [self pointHistoryToString]];
}


-(NSString*)pointHistoryToString;
{
    NSMutableString *mStr = [[NSMutableString alloc] init];
    
    for (IssueHistory *h in self.pointHistory)
    {
        [mStr appendString:[h description]];
        [mStr appendString:@"\n"];
    }
    
    if(mStr.length !=0)
        [mStr deleteCharactersInRange:NSMakeRange([mStr length]-1,1)];
    
    return mStr;
}



@end
