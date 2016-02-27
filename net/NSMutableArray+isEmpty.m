//
//  NSMutableArray+isEmpty.m
//  net
//
//  Created by user on 2/26/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NSMutableArray+isEmpty.h"

@implementation NSMutableArray (isEmpty)

- (BOOL) isEmpty {
    if ([self count] == 0)
        return YES;
    return NO;
}

@end
