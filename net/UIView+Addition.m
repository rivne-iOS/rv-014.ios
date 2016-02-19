//
//  UIView+Addition.m
//  net
//
//  Created by user on 2/17/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "UIView+Addition.h"

@implementation UIView (Addition)

- (void) setBorderForColor:(UIColor *)color width:(float)width radius:(float)radius {
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [color CGColor];
    self.layer.borderWidth = width;
    self.layer.cornerRadius = radius;
}

@end
