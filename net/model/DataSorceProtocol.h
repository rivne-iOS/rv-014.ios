//
//  DataSorceProtocol.h
//  net
//
//  Created by Admin on 10.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#ifndef net_DataSorceProtocol_h
#define net_DataSorceProtocol_h
#import "User.h"
#import "Issue.h"
#import "IssueCategory.h"
#import <UIKit/UIKit.h>


@protocol DataSorceProtocol <NSObject>


-(void)requestCategories:(void (^)(NSArray<IssueCategory*> * issueCategories, NSError *error))viewControllerHandler;

-(void)requestAllUsers:(void (^)(NSArray <NSDictionary <NSString*,NSString*> *> *userDictionaries, NSError *error))handler;


-(void)requestCommentsWithIssueID:(NSNumber*)issueID
                       andHandler:(void (^)(NSArray <NSDictionary <NSString*,id> *> *commentDics, NSError *error))handler;


-(void)requestSendNewComment:(NSString*)strComment forIssueID:(NSNumber*)issueID
                  andHandler:(void (^)(NSArray <NSDictionary <NSString*,id> *> *commentDics, NSError *error))handler;


-(void)requestImageWithName:(NSString*)name andHandler:(void (^)(UIImage *image, NSError *error))viewControllerHandler;

-(void)requestLogInWithUser:(NSString*)user
                    andPass:(NSString*)pass
   andViewControllerHandler:(void (^)(User *resPerson, NSError *error))viewControllerHandler;


-(void)requestSingUpWithUser:(User*)user
    andViewControllerHandler:(void (^)(User *resPerson, NSError *error))viewControllerHandler;

-(void)requestSignOutWithHandler:(void (^)(NSString * stringAnswer, NSError *error))viewControllerHandler;

-(void)requestChangeStatusWithID:(NSNumber*)issueIdNumber
                        toStatus:(NSString*)stringStatus
        andViewControllerHandler:(void (^)(NSString *stringAnswer, Issue *issue, NSError *error))viewControllerHandler; // e.g. user is not logined (string answer parametr)


@end


#endif
