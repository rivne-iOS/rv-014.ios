//
//  BPHTTPWizard.m
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import "HTTPConnector.h"

@implementation HTTPConnector

-(instancetype)init
{
    if(self = [super init])
    {
        _globalURL = @"https://bawl-rivne.rhcloud.com/";
        _allPersURL = @"users/all";
        _allPointsURL = @"issue/all";
        _userLogIn = @"users/auth/login";
    }
    return self;
}


-(void)requestUsers:(void(^)(NSData* data, NSError *error))dataSorceHandler
{
    NSURL *url = [NSURL URLWithString: [self.globalURL stringByAppendingString:self.allPersURL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:
                                      ^(NSData *data, NSURLResponse *response, NSError *error)
    {
        // result with error (for testing)
        //        dataSorceHandler(data, [[NSError alloc] init]);
        dataSorceHandler(data, error);
    }
    ];

    [dataTask resume];
    
}

-(void)requestLogInWithUser:(NSString*)user
                    andPass:(NSString*)pass
        andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler;
{
    NSURL *url = [NSURL URLWithString: [self.globalURL stringByAppendingString:self.userLogIn]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                         user, @"login",
                         pass, @"password", nil];
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:0
                                                         error:&err];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // two headers, that our server doesn't need
    // [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // [request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:
    ^(NSData *data, NSURLResponse *response, NSError *error)
    {
      // result with error (for testing)
      //        dataSorceHandler(data, [[NSError alloc] init]);
      dataSorceHandler(data, error);
    }
    ];
    
    [dataTask resume];
    
}




    

    
    
    
    


@end
