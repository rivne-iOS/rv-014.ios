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

#import <CoreText/CTFontManager.h>

@interface NetworkDataSorce()



@end


@implementation NetworkDataSorce




-(void)requestCategories:(void (^)(NSArray<IssueCategory*> * issueCategories, NSError *error))viewControllerHandler
{
    HTTPConnector *connector = [[HTTPConnector alloc] init];
    [connector requestCategories:^(NSData *data, NSError *error) {
        NSMutableArray <IssueCategory*> *issueCategories = nil;
        if (data.length > 0 && error==nil)
        {
            NSArray <NSDictionary*> *issueCategoryDics = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            issueCategories = [[NSMutableArray alloc] init];
            
            for(NSDictionary *issueCategoryDic in issueCategoryDics)
            {
                IssueCategory *issueCategory = [[IssueCategory alloc] initWithDictionary:issueCategoryDic];
                [issueCategories addObject:issueCategory];
            }
        }
        viewControllerHandler(issueCategories, error);

    }];

}


-(void)requestAllUsers:(void (^)(NSArray <NSDictionary <NSString*,NSString*> *> *userDictionaries, NSError *error))handler
{
    HTTPConnector *connector = [[HTTPConnector alloc] init];
    [connector requestUsers:^(NSData *data, NSError *error) {
        NSArray <NSDictionary<NSString*,NSString*>*> *userDics = nil;
        if(data.length>0 && error==nil)
        {
            userDics= [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if (![userDics isKindOfClass:[NSArray class]] || error != nil)
            {
                userDics=nil;
            }
        }
        handler(userDics, error);
    }];
}



-(void)requestCommentsWithIssueID:(NSNumber*)issueID
                       andHandler:(void (^)(NSArray <NSDictionary <NSString*,id> *> *commentDics, NSError *error))handler;
{
    HTTPConnector *connector = [[HTTPConnector alloc] init];
    [connector requestCommentWithID:[issueID stringValue] andDataSorceHandler:^(NSData *data, NSError *error) {
        if(error!=nil || data==nil)
        {
            handler(nil, error);
            return;
        }
        
        NSArray <NSDictionary<NSString*,id>*> *commentDics = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        handler(commentDics, error);

    }];
    
}

-(void)requestSendNewComment:(NSString*)strComment forIssueID:(NSNumber*)issueID
                  andHandler:(void (^)(NSArray <NSDictionary <NSString*,id> *> *commentDics, NSError *error))handler
{
    NSDictionary *dictionary = @{@"comment" : strComment};
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&err];
    
    HTTPConnector *con = [[HTTPConnector alloc] init];
    [con requestSendNewCommentWithIssueID:[issueID stringValue] andPosData:postData andDatasorceHandler:^(NSData *data, NSError *error) {
        if(error!=nil || data==nil)
        {
            handler(nil, error);
            return;
        }
        
        NSArray <NSDictionary<NSString*,id>*> *commentDics = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        handler(commentDics, error);
    }];
    

}


-(void)requestImageWithName:(NSString*)name andHandler:(void (^)(UIImage *image, NSError *error))viewControllerHandler
{
    HTTPConnector *connector = [[HTTPConnector alloc] init];
    [connector requestImageWithName:name andDataSorceHandler:^(NSData *data, NSError *error) {
        UIImage *image = nil;
        if (data.length > 0 && error==nil)
        {
            image = [[UIImage alloc] initWithData:data];
            
        }
        viewControllerHandler(image, error);
    }];

}


-(void)requestSignOutWithHandler:(void (^)(NSString * stringAnswer, NSError *error))viewControllerHandler
{
    HTTPConnector *wizard = [[HTTPConnector alloc] init];
    [wizard requestSignOutWithHandler:^(NSData *data, NSError *error) {
        NSString *resStr = nil;
        if (data.length > 0 && error==nil)
        {
            resStr = [Parser parseAnswer:data andReturnObjectForKey:@"message"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userDictionary"];
        }
        viewControllerHandler(resStr, error);

    }];
}


-(void)requestLogInWithUser:(NSString*)login
                    andPass:(NSString*)password
   andViewControllerHandler:(void (^)(User *resPerson, NSError *error))viewControllerHandler{
    
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
                 User *tempUser = nil;
        if(data.length >0 && error == nil)
        {
            
            NSMutableDictionary *userDic = [[NSJSONSerialization JSONObjectWithData:data
                                                                            options:0
                                                                              error:NULL] mutableCopy];
            if([userDic count]>1)
            {
                if ([[userDic objectForKey:@"AVATAR"] isEqual:[NSNull null]])
                    [userDic setObject:@"defaultUser" forKey:@"AVATAR"];
                [[NSUserDefaults standardUserDefaults] setObject:userDic forKey:@"userDictionary"];
                tempUser = [[User alloc] initWitDictionary:userDic];
            }
        }
             
        viewControllerHandler(tempUser, error);

        }];
    
}


-(void)requestSingUpWithUser:(User*)user
    andViewControllerHandler:(void (^)(User *resPerson, NSError *error))viewControllerHandler
{
    NSDictionary *dictionary = [user puckToDictionary];
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:0
                                                             error:&err];
    HTTPConnector *connector = [[HTTPConnector alloc] init];
    [connector requestSingUpWithData:postData
                 andDataSorceHandler:^(NSData *data, NSError *error) {
                     User *user = nil;
                     if(data.length >0 && error == nil)
                     {
                         NSMutableDictionary *userDic = [[NSJSONSerialization JSONObjectWithData:data
                                                                                   options:0
                                                                                     error:NULL] mutableCopy];

                         if([userDic count]>1)
                         {
                             [userDic setObject:@"defaultUser" forKey:@"AVATAR"];
                             [[NSUserDefaults standardUserDefaults] setObject:userDic forKey:@"userDictionary"];
                             user = [[User alloc] initWitDictionary:userDic];
                         }
                         else
                         {
                             NSLog(@"Error with sign up! \n\n");
                             for(NSString *str in [userDic allKeys])
                             {
                                 NSLog(@"%@ - %@", str, [userDic objectForKey:str]);
                             }
                         }
                     }
                     viewControllerHandler(user, error);
                 }];
}



-(void)requestChangeStatusWithID:(NSNumber*)issueIdNumber
                        toStatus:(NSString*)stringStatus
        andViewControllerHandler:(void (^)(NSString *stringAnswer, Issue *issue, NSError *error))viewControllerHandler
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
        NSString *stringAnswer = nil;
        Issue *issue = nil;
        if (data.length > 0 && error==nil)
        {
            stringAnswer = [Parser parseAnswer:data andReturnObjectForKey:@"message"];
            
            if(stringAnswer == nil)
            {
                NSDictionary *issueDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
                issue = [[Issue alloc] initWithDictionary:issueDictionary];
            }
        }
        viewControllerHandler(stringAnswer, issue, error);

    }];

}


@end
