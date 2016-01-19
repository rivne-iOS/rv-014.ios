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

@property (retain, nonatomic) Issue *issue;
@property (retain, nonatomic) NSMutableArray *issueHistory;

@property (strong, nonatomic) IBOutlet UILabel *issueTitle;

@end
