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
@property (weak, nonatomic) NSMutableArray *issueHistory;

@property (weak, nonatomic) IBOutlet UILabel *issueTitle;

@end
