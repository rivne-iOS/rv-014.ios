//
//  BPHTTPWizard.m
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import "HTTPConnector.h"
@interface HTTPConnector()

@property(strong, nonatomic)NSString *globalURL;
@property(strong, nonatomic)NSString *allPersURL;
@property(strong, nonatomic)NSString *allPointsURL;
@property(strong, nonatomic)NSString *userLogIn;
@property(strong, nonatomic)NSString *userSingUp;
@property(strong, nonatomic)NSString *userSignOut;
@property(strong, nonatomic)NSString *changeIssueStatus;

-(void)postRequest:(NSData*) postData
             toURL:(NSString*) textUrl
        andHandler:(void(^)(NSData *data, NSError *error))handler;

-(void)getRequestBlankToUrl:(NSString*)textUrl
                 andHandler:(void(^)(NSData* data, NSError *error))dataSorceHandler;

-(void)putRequestToUrl:(NSString*)textUrl
                 andHandler:(void(^)(NSData* data, NSError *error))dataSorceHandler;


@end


@implementation HTTPConnector

-(instancetype)init
{
    if(self = [super init])
    {
        _globalURL = @"https://bawl-rivne.rhcloud.com/";
        _allPersURL = @"users/all";
        _allPointsURL = @"issue/all";
        _userLogIn = @"users/auth/login";
        _userSingUp = @"users";
        _userSignOut = @"users/auth/logout";
        _changeIssueStatus = @"issue/issueIDNumber/resolve";
        
    }
    return self;
}


-(void)requestUsers:(void(^)(NSData* data, NSError *error))dataSorceHandler
{
    [self getRequestBlankToUrl:[self.globalURL stringByAppendingString:self.allPersURL] andHandler:dataSorceHandler];
}

-(void)requestSignOutWithHandler:(void (^)(NSData *data, NSError *error))dataSorceHandler
{
    [self getRequestBlankToUrl:[self.globalURL stringByAppendingString:self.userSignOut] andHandler:dataSorceHandler];
}

-(void)requestLogInWithData:(NSData*)data
        andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler;
{
    [self postRequest:data toURL:[self.globalURL stringByAppendingString:self.userLogIn] andHandler:dataSorceHandler];
}

-(void)requestSingUpWithData:(NSData*)data
        andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler;
{
    [self postRequest:data toURL:[self.globalURL stringByAppendingString:self.userSingUp] andHandler:dataSorceHandler];
}

-(void)requestChangeStatusWithStringIssueID:(NSString*)strindIssueID
                        andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler
{
    [self putRequestToUrl:[[self.globalURL stringByAppendingString:self.changeIssueStatus] stringByReplacingOccurrencesOfString:@"issueIDNumber" withString:strindIssueID] andHandler:dataSorceHandler];
}


-(void)postRequest:(NSData*) postData
             toURL:(NSString*) textUrl
        andHandler:(void(^)(NSData *data, NSError *error))handler
{
    NSURL *url = [NSURL URLWithString: textUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          // result with error (for testing)
                                          //        dataSorceHandler(data, [[NSError alloc] init]);
                                          handler(data, error);
                                      }
                                      ];
    
    [dataTask resume];
    
}

-(void)getRequestBlankToUrl:(NSString*)textUrl andHandler:(void(^)(NSData* data, NSError *error))handler
{
    NSURL *url = [NSURL URLWithString:textUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          // result with error (for testing)
                                          //        dataSorceHandler(data, [[NSError alloc] init]);
                                          handler(data, error);
                                      }
                                      ];
    
    [dataTask resume];
    
}

    
-(void)putRequestToUrl:(NSString*)textUrl
            andHandler:(void(^)(NSData* data, NSError *error))handler
{
    NSURL *url = [NSURL URLWithString: textUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          // result with error (for testing)
                                          //        dataSorceHandler(data, [[NSError alloc] init]);
                                          handler(data, error);
                                      }
                                      ];
    
    [dataTask resume];
    
}
    
    
    
    


@end
