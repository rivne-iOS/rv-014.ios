//
//  UIViewController+backViewController.m
//  net
//
//  Created by user on 2/18/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "UIViewController+backViewController.h"

@implementation UIViewController (backViewController)

- (UIViewController *) backViewController {
    NSInteger numberOfViewController = self.navigationController.viewControllers.count;
    
    if (numberOfViewController < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewController - 2];
}

@end
