//
//  IssueHistoryViewController.m
//  net
//
//  Created by user on 1/19/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "IssueHistoryViewController.h"

@interface IssueHistoryViewController ()
@property (weak, nonatomic) IBOutlet UITableView *issueTable;

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
                                            
                                            UIColor *color = [UIColor colorWithRed:(255/225.0f) green:(0/255.0f) blue:(137/255.0f) alpha:1];
                                            NSDictionary *attrs = @{ NSForegroundColorAttributeName : color };
                                            
                                            UIActivityIndicatorView *ac = [[UIActivityIndicatorView alloc]
                                                                           initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                                            [ac startAnimating];
                                            
                                            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
                                            [view addSubview:ac];
                                            
                                            _weakSelf.issueTable.tableHeaderView = view;
                                            
                                            for (NSDictionary *issue in issuesDictionaryArray) {
                                                NSAttributedString *date = [[NSAttributedString alloc] initWithString:issue[@"DATE"] attributes:attrs];
                                                
                                                [_weakSelf.issueHistory addObject:[NSString stringWithFormat:@"%@: %@ %@",date, issue[@"USER"], issue[@"ACTION"]]];
                                            }
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [_weakSelf.issueTable reloadData];
                                                
                                                [ac stopAnimating];
                                            });
                                        }
                                    }] resume];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.issueTitle setText:self.issue.description];
    self.issueTitle.textColor = [UIColor colorWithRed:(255/225.0f) green:(0/255.0f) blue:(137/255.0f) alpha:1];
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
    static NSString *cellIdentifier = @"Cell Identifier";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    NSString *issueHistoryCell = [self.issueHistory objectAtIndex:[indexPath row]];
    
    [cell.textLabel setText:issueHistoryCell];
    
    return cell;
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
