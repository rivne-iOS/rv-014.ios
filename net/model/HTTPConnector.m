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
@property(strong, nonatomic)NSString *changeIssueStatusToResolve;
@property(strong, nonatomic)NSString *changeIssueStatusToApproveCancel;
@property(strong, nonatomic)NSString *allCategories;
@property(strong, nonatomic)NSString *issueImage;
@property(strong, nonatomic)NSString *defaultIssueImage;
@property(strong, nonatomic)NSString *defaultUserImage;


-(void)postRequest:(NSData*) postData
             toURL:(NSString*) textUrl
        andHandler:(void(^)(NSData *data, NSError *error))handler;

-(void)getRequestBlankToUrl:(NSString*)textUrl
                 andHandler:(void(^)(NSData* data, NSError *error))dataSorceHandler;

-(void)putRequestToUrl:(NSString*)textUrl
              withData:(NSData *) data
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
        _changeIssueStatusToResolve = @"issue/issueIDNumber/resolve";
        _changeIssueStatusToApproveCancel = @"issue";
        _allCategories = @"categories/all";
        _issueImage = @"image/";
        _defaultIssueImage = @"no_attach.png";
        _defaultUserImage = @"no_avatar.png";
        
    }
    return self;
}


-(void)requestUsers:(void(^)(NSData* data, NSError *error))dataSorceHandler
{
    [self getRequestBlankToUrl:[self.globalURL stringByAppendingString:self.allPersURL] andHandler:dataSorceHandler];
}

-(void)requestCategories:(void(^)(NSData *data, NSError *error))dataSorceHandler
{
    [self getRequestBlankToUrl:[self.globalURL stringByAppendingString:self.allCategories] andHandler:dataSorceHandler];
}
-(void)requestImageWithName:(NSString*)name andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler
{
    if ([name isEqual:[NSNull null]])
        name = self.defaultIssueImage;
    else if ([name isEqualToString:@"defaultUser"])
        name = self.defaultUserImage;
    else if ([name isEqualToString:@"defaultIssue"])
        name = self.defaultIssueImage;
        
    [self getRequestBlankToUrl:[NSString stringWithFormat:@"%@%@%@", self.globalURL, self.issueImage, name] andHandler:dataSorceHandler];
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
                                   toStatus:(NSString*)stringStatus
                                   withData:(NSData*)data
                        andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler
{
    if ([stringStatus isEqualToString:@"APPROVED"] || [stringStatus isEqualToString:@"CANCELED"])
    {
        [self putRequestToUrl:[NSString stringWithFormat:@"%@%@/%@", self.globalURL, self.changeIssueStatusToApproveCancel, strindIssueID]
                     withData:data
                   andHandler:dataSorceHandler];
    }
    else
    {
        [self putRequestToUrl:[[self.globalURL stringByAppendingString:self.changeIssueStatusToResolve] stringByReplacingOccurrencesOfString:@"issueIDNumber" withString:strindIssueID]
                     withData:nil
                   andHandler:dataSorceHandler];
    }
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
              withData:(NSData *) data
            andHandler:(void(^)(NSData* data, NSError *error))handler
{
    NSURL *url = [NSURL URLWithString: textUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if(data != nil)
    {
        [request setHTTPBody:data];
    }
    
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
