//
//  NSString+stringIsEmpry.m
//  net
//
//  Created by user on 2/19/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NSString+stringIsEmpry.h"

@implementation NSString (stringIsEmpty)

+ (BOOL) stringIsEmpty:(NSString *)string {
    if (string == nil)
        return YES;
    else if ([string length] == 0)
        return YES;
    else {
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([string length] == 0)
            return YES;
    }
    return NO;
}

@end
