//
//  CurrentItemsDelegate.h
//  net
//
//  Created by Admin on 15.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CurrentItemsDelegate <NSObject>

@optional
-(void)userImageDidLoad;
-(void)issueImageDidLoad;

@end
