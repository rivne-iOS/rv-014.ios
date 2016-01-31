//
//  NetworkDataSorce.m
//  net
//
//  Created by Admin on 10.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import "NetworkDataSorce.h"
#import "HTTPConnector.h"
#import "User.h"
#import "Issue.h"
#import "Parser.h"



@implementation NetworkDataSorce


-(void)requestUsers:(void (^)(NSArray * stringPers))viewControllerHandler withErrorHandler:(void(^)(NSError *error)) errorHandler
{
    HTTPConnector *wizard = [[HTTPConnector alloc] init];
    [wizard requestUsers:^(NSData * data, NSError *error)
    {
        if (data.length > 0 && error == nil)
        {
            NSArray *arrOfPers = [Parser parseDataToArrayOfUsers:data];
            NSMutableArray *arrOfStringPers = [[NSMutableArray alloc] init];
            for (User *p in arrOfPers)
            {
                [arrOfStringPers addObject: [[p description] stringByAppendingString:@"\n\n"]];
            }

            NSLog(@"Created arrOfStringPers. First Pers:%@", arrOfStringPers[0]);
            
            viewControllerHandler(arrOfStringPers);
            
        }
        else if (error !=  nil)
        {
            errorHandler(error);
        }

    }];
}

-(void)requestSignOutWithHandler:(void (^)(NSString * stringAnswer))viewControllerHandler andErrorHandler:(void(^)(NSError *error)) errorHandler
{
    HTTPConnector *wizard = [[HTTPConnector alloc] init];
    [wizard requestSignOutWithHandler:^(NSData *data, NSError *error) {
        if (data.length > 0 && error==nil)
        {
            viewControllerHandler([Parser parseAnswer:data andReturnObjectForKey:@"message"]);
        }
        else if(error != nil)
        {
            errorHandler(error);
        }
    }];
}


-(void)requestLogInWithUser:(NSString*)user
                    andPass:(NSString*)pass
   andViewControllerHandler:(void (^)(User *resPerson))viewControllerHandler
            andErrorHandler:(void(^)(NSError *error)) errorHandler;
{
    HTTPConnector *wizard = [[HTTPConnector alloc] init];
    
    [wizard requestLogInWithData:[Parser parseToDataWithLogIn:user andPassword:pass]
             andDataSorceHandler:^(NSData *data, NSError *error) {
        if(data.length >0 && error == nil)
        {
            viewControllerHandler([Parser parseDataToUser:data]);
        }
             }];
    
}


-(void)requestSingUpWithUser:(User*)user
    andViewControllerHandler:(void (^)(User *resPerson))viewControllerHandler
             andErrorHandler:(void(^)(NSError *error)) errorHandler
{
    HTTPConnector *connector = [[HTTPConnector alloc] init];
    [connector requestSingUpWithData:[Parser parseUserToData:user]
                 andDataSorceHandler:^(NSData *data, NSError *error) {
                     if(data.length >0 && error == nil)
                     {
                         viewControllerHandler([Parser parseDataToUser:data]);
                     }
                     else if (error!=nil)
                     {
                         errorHandler(error);
                     }
                 }];

}



-(void)requestChangeStatusWithID:(NSNumber*)issueIdNumber
                        toStatus:(NSString*)stringStatus
        andViewControllerHandler:(void (^)(NSString *stringAnswer, Issue *issue))viewControllerHandler // e.g. user is not logined
                 andErrorHandler:(void(^)(NSError *error)) errorHandler;
{
    HTTPConnector *wizard = [[HTTPConnector alloc] init];
    NSData *postData = nil;
    
    if ([stringStatus isEqualToString:@"APPROVED"] || [stringStatus isEqualToString:@"CANCELED"])
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:stringStatus, @"status", nil];
        postData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:0
                                                             error:NULL];
    }
    
    [wizard requestChangeStatusWithStringIssueID:[NSString stringWithFormat:@"%@", issueIdNumber]
                                        toStatus:stringStatus
                                        withData:postData
                             andDataSorceHandler:^(NSData *data, NSError *error) {
        if (data.length > 0 && error==nil)
        {
            NSString *stringAnswer = [Parser parseAnswer:data andReturnObjectForKey:@"message"];
            Issue *issue = nil;
            
            if(stringAnswer == nil)
            {
                NSDictionary *issueDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                issue = [[Issue alloc] initWithDictionary:issueDictionary];
            }
            viewControllerHandler(stringAnswer, issue);
        }
        else if(error != nil)
        {
            errorHandler(error);
        }
    }];

}

@end
