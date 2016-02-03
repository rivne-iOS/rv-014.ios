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
    return [UIColor bawlRedColorWithAlpha:1.0];
}

+(UIColor*)bawlRedColorWithAlpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:0.88235294117647056 green:0.21176470588235294 blue:0.33333333333333331 alpha:alpha];
}
@end
