//
//  DescriptionViewController.h
//  net
//
//  Created by Admin on 19/01/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Issue.h"
#import "User.h"
#import "MapViewController.h"

@interface DescriptionViewController : UIViewController


-(void)setDataToView;
-(void)prepareUIChangeStatusElements;
-(void)clearOldDynamicElements;

@end
