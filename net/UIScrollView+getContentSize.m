//
//  UIScrollView.m
//  net
//
//  Created by user on 3/1/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "UIScrollView+getContentSize.h"

@implementation UIScrollView (getContentSize)

-(CGSize) getContentSize {
    CGRect contentRect = CGRectZero;
    
    for (UIView *view in self.subviews) {
        if (!view.hidden)
            contentRect = CGRectUnion(contentRect, view.frame);
    }
    
    return contentRect.size;
}

@end
