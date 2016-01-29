//
//  IssueHistoryViewController.m
//  net
//
//  Created by user on 1/19/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "IssueHistoryViewController.h"

static NSString * const kSimpleTableIdentifier = @"SampleTableCell";

@interface IssueHistoryViewController ()
@property (weak, nonatomic) IBOutlet UITableView *issueTable;
//@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation IssueHistoryViewController

-(void) requestIssueHistory {
    NSString *requestString = [NSString stringWithFormat:@"https://bawl-rivne.rhcloud.com/issue/%@/history",[self.issue.issueId stringValue]];
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __weak  IssueHistoryViewController *_weakSelf = self;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                        if (data.length > 0 && connectionError == nil)
                                        {
                                            NSArray *issuesDictionaryArray = [NSJSONSerialization JSONObjectWithData:data
                                                                                                             options:0
                                                                                                               error:NULL];
                                            
                                            UIColor *color = [[UIColor alloc] initWithRed: (255/225.0f) green:(0/255.0f) blue:(137/255.0f) alpha:1];
                                            NSDictionary *attrs = @{ NSForegroundColorAttributeName : color };
                                            
                                            [_weakSelf.issueHistory removeAllObjects];
                                            
                                            for (NSDictionary *issue in issuesDictionaryArray) {
                                                
                                                NSAttributedString *date = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",issue[@"DATE"]] attributes:attrs];
                                                NSAttributedString *user = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", issue[@"USER"]]];
                                                NSAttributedString *action =[[NSAttributedString alloc] initWithString:issue[@"ACTION"]];
                                                
                                                NSMutableDictionary *oneCell = [[NSMutableDictionary alloc] init];
                                                [oneCell setValue:date forKey:@"date"];
                                                [oneCell setValue:user forKey:@"user"];
                                                [oneCell setValue:action forKey:@"action"];
                                                
                                                [_weakSelf.issueHistory addObject:oneCell];
                                            }
                                            
                                            [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                        }
                                    }] resume];
    
}

-(void) reloadData {
    [self.issueTable reloadData];
    
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.issueTitle setText:self.issue.issueDescription];
    self.issueHistory = [[NSMutableArray alloc] init];
    self.issueTitle.textColor = [UIColor colorWithRed:(255/225.0f) green:(0/255.0f) blue:(137/255.0f) alpha:1];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(requestIssueHistory) forControlEvents:UIControlEventValueChanged];
    
    [self.issueTable registerNib:[UINib nibWithNibName:@"CustomTableCell" bundle:nil] forCellReuseIdentifier:kSimpleTableIdentifier];
    
    [self requestIssueHistory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.issueHistory count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomTableCell *cell = [tableView dequeueReusableCellWithIdentifier:kSimpleTableIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSMutableDictionary *singleAction = [self.issueHistory objectAtIndex:indexPath.row];
    
    NSMutableAttributedString *userAction = [[NSMutableAttributedString alloc] init];
    
    [userAction appendAttributedString:singleAction[@"user"]];
    [userAction appendAttributedString:singleAction[@"action"]];
    
    cell.date.attributedText = singleAction[@"date"];
    cell.action.attributedText = userAction;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.issueHistory) {
        
        self.issueTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.issueTable.backgroundView = messageLabel;
        self.issueTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
