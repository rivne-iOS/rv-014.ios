//
//  IssueHistoryViewController.m
//  net
//
//  Created by user on 1/19/16.
//  Copyright © 2016 Admin. All rights reserved.
//
#import "MapViewController.h"
#import "IssueHistoryViewController.h"
#import "UIColor+Bawl.h"
#import "ProfileViewController.h"
#import "IssueHistory.h"
#import "CurrentItems.h"
#import "NSMutableArray+isEmpty.h"

static NSString * const kSimpleTableIdentifier = @"SampleTableCell";

@interface IssueHistoryViewController ()
@property (weak, nonatomic) IBOutlet UITableView *issueTable;
@property NSUInteger userID;

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
                                            
                                            UIColor *color = [UIColor bawlRedColor];
                                            NSDictionary *attrs = @{ NSForegroundColorAttributeName : color };
                                            
                                            [_weakSelf.issueHistory removeAllObjects];
                                            
                                            for (NSDictionary *issue in issuesDictionaryArray) {
                                                
                                                NSAttributedString *date = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",issue[@"DATE"]] attributes:attrs];
                                                NSAttributedString *user = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", issue[@"USER"]] attributes:attrs];
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
    self.issueTitle.textColor = [UIColor bawlRedColor];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor bawlRedColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor bawlRedColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(requestIssueHistory) forControlEvents:UIControlEventValueChanged];
    
    [self.issueTable registerNib:[UINib nibWithNibName:@"CustomTableCell" bundle:nil] forCellReuseIdentifier:kSimpleTableIdentifier];
    
    [self requestIssueHistory];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.tabBarController.tabBar.items objectAtIndex:2].title = @"History";
    self.issue = [CurrentItems sharedItems].issue;
    [self.issueTitle setText:self.issue.issueDescription];
    [self requestIssueHistory];
    [self.mapDelegate showTabBar];
    self.tabBarController.tabBar.hidden = NO;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [self.issueHistory removeAllObjects];
    [self.issueTable reloadData];
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
    if (![self.issueHistory isEmpty]) {
        
        self.issueTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.issueTable.backgroundView = nil;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *history = self.issue.history;
    
    NSDictionary *currentHistory = history[indexPath.row];
    
    self.userID = [currentHistory[@"USER_ID"] integerValue];
    
    [self performSegueWithIdentifier:@"showProfile" sender:self];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showProfile"]) {
        if([segue.destinationViewController isKindOfClass:[ProfileViewController class]])
        {
            ProfileViewController *profileViewController = (ProfileViewController*)segue.destinationViewController;
            profileViewController.userID = self.userID;
            profileViewController.isLogged = self.isLogged;
            profileViewController.dataSorce = self.dataSorce;
            profileViewController.mapViewDelegate = self.mapDelegate;
        }
    }
}
@end
