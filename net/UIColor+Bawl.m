//
//  UIColor+Bawl.m
//  net
//
//  Created by Admin on 02.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "UIColor+Bawl.h"

@implementation UIColor (Bawl)

+(UIColor*)bawlRedColor
{
    static UIColor *bawlRedColor = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        bawlRedColor = [UIColor bawlRedColorWithAlpha:1.0];
    });
    return bawlRedColor;
}

+(UIColor*)bawlRedColor03alpha
{
    static UIColor *bawlRedColor = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        bawlRedColor = [UIColor bawlRedColorWithAlpha:0.3];
    });
    return bawlRedColor;
}

+(UIColor*)bawlRedColorWithAlpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:0.88235294117647056 green:0.21176470588235294 blue:0.33333333333333331 alpha:alpha];
}
@end
