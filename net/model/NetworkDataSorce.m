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

@interface NetworkDataSorce()



@end


@implementation NetworkDataSorce




-(void)requestCategories:(void (^)(NSArray<IssueCategory*> * issueCategories))viewControllerHandler withErrorHandler:(void(^)(NSError *error)) errorHandler
{
    HTTPConnector *connector = [[HTTPConnector alloc] init];
    [connector requestCategories:^(NSData *data, NSError *error) {
        if (data.length > 0 && error==nil)
        {
            NSArray <NSDictionary*> *issueCategoryDics = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSMutableArray <IssueCategory*> *issueCategories = [[NSMutableArray alloc] init];
            
            for(NSDictionary *issueCategoryDic in issueCategoryDics)
            {
                IssueCategory *issueCategory = [[IssueCategory alloc] initWithDictionary:issueCategoryDic];
                [issueCategories addObject:issueCategory];
            }
            viewControllerHandler(issueCategories);
        }
        else if(error != nil)
        {
            errorHandler(error);
        }

    }];

}

-(void)requestImageWithName:(NSString*)name andHandler:(void (^)(UIImage *image))viewControllerHandler withErrorHandler:(void(^)(NSError *error)) errorHandler
{
    HTTPConnector *connector = [[HTTPConnector alloc] init];
    [connector requestImageWithName:name andDataSorceHandler:^(NSData *data, NSError *error) {
        if (data.length > 0 && error==nil)
        {
            UIImage *image = [[UIImage alloc] initWithData:data];
            viewControllerHandler(image);
        }
        else if(error != nil)
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
            NSString *resStr = [Parser parseAnswer:data andReturnObjectForKey:@"message"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userDictionary"];
            viewControllerHandler(resStr);
        }
        else if(error != nil)
        {
            errorHandler(error);
        }
    }];
}


-(void)requestLogInWithUser:(NSString*)login
                    andPass:(NSString*)password
   andViewControllerHandler:(void (^)(User *user))viewControllerHandler
            andErrorHandler:(void(^)(NSError *error)) errorHandler;
{
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                login, @"login",
                                password, @"password", nil];
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&err];
    
    HTTPConnector *connector = [[HTTPConnector alloc] init];
    [connector requestLogInWithData:postData
             andDataSorceHandler:^(NSData *data, NSError *error) {
        if(data.length >0 && error == nil)
        {
            NSDictionary *userDic = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
            User *tempUser = nil;
            if ([userDic count] >1)
            {
                [[NSUserDefaults standardUserDefaults] setObject:userDic forKey:@"userDictionary"];
                tempUser = [[User alloc] initWitDictionary:userDic];
            }
            viewControllerHandler(tempUser);
        }
        else
        {
            errorHandler(error);
        }
             }];
    
}


-(void)requestSingUpWithUser:(User*)user
    andViewControllerHandler:(void (^)(User *user))viewControllerHandler
             andErrorHandler:(void(^)(NSError *error)) errorHandler
{
    NSDictionary *dictionary = [user puckToDictionary];
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:0
                                                             error:&err];
    HTTPConnector *connector = [[HTTPConnector alloc] init];
    [connector requestSingUpWithData:postData
                 andDataSorceHandler:^(NSData *data, NSError *error) {
                     if(data.length >0 && error == nil)
                     {
                         NSDictionary *userDic = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:0
                                                                                     error:NULL];
                         User *user = nil;
                         if([userDic count]>1)
                         {
                             [[NSUserDefaults standardUserDefaults] setObject:userDic forKey:@"userDictionary"];
                             user = [[User alloc] initWitDictionary:userDic];
                         }
                         viewControllerHandler(user);
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
