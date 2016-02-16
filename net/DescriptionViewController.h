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

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
//@property (strong,nonatomic) UIImage *image;

@property (weak, nonatomic) MapViewController *mapViewControllerDelegate;


-(void)setDataToView;
-(void)prepareUIChangeStatusElements;
-(void)clearOldDynamicElements;

@end
