//
//  IssueHistoryViewController.h
//  net
//
//  Created by user on 1/19/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Issue.h"

@interface IssueHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Issue *issue;
@property (strong, nonatomic) NSMutableArray *issueHistory;

@property (strong, nonatomic) IBOutlet UILabel *issueTitle;

@end
