//
//  IssueHistoryViewController.m
//  net
//
//  Created by user on 1/19/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "IssueHistoryViewController.h"

@interface IssueHistoryViewController ()

@end

@implementation IssueHistoryViewController

-(void) requestIssueHistory {
    NSString *requestString = [NSString stringWithFormat:@"https://bawl-rivne.rhcloud.com/issue/%@/history",[self.issue.ID stringValue]];
    
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [[[NSURLSession sharedSession]dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                        if (data.length > 0 && connectionError == nil)
                                        {
                                            NSArray *issuesDictionaryArray = [NSJSONSerialization JSONObjectWithData:data
                                                                                                             options:0
                                                                                                               error:NULL];
                                            
                                            for (NSDictionary *issue in issuesDictionaryArray) {
                                                [self.issueHistory addObject:[NSString stringWithFormat:@"%@: %@",issue[@"data"],issue[@"action"]]];
                                            }
                                            
                                        }
                                    }] resume];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.issueTitle setText:self.issue.DESCRIPTION];
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
