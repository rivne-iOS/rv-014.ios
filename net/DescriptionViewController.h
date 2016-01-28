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

@interface DescriptionViewController : UIViewController

@property (strong, nonatomic) Issue *currentIssue;
@property (strong, nonatomic) User *currentUser;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;


@end
