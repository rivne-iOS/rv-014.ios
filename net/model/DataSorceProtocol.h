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


-(void)requestCategories:(void (^)(NSArray<IssueCategory*> * issueCategories))viewControllerHandler withErrorHandler:(void(^)(NSError *error)) errorHandler;

-(void)requestAllUsers:(void (^)(NSArray <NSDictionary <NSString*,NSString*> *> *userDictionaries))handler withErrorHandler:(void(^)(NSError *error)) errorHandler;

-(void)requestComment:(void (^)(NSDictionary <NSString*,NSString*> *commentDic))handler withErrorHandler:(void(^)(NSError *error)) errorHandler;


-(void)requestImageWithName:(NSString*)name andHandler:(void (^)(UIImage *image))viewControllerHandler withErrorHandler:(void(^)(NSError *error)) errorHandler;

-(void)requestLogInWithUser:(NSString*)user
                    andPass:(NSString*)pass
   andViewControllerHandler:(void (^)(User *resPerson))viewControllerHandler
            andErrorHandler:(void(^)(NSError *error)) errorHandler;

-(void)requestSingUpWithUser:(User*)user
   andViewControllerHandler:(void (^)(User *resPerson))viewControllerHandler
            andErrorHandler:(void(^)(NSError *error)) errorHandler;

-(void)requestSignOutWithHandler:(void (^)(NSString * stringAnswer))viewControllerHandler andErrorHandler:(void(^)(NSError *error)) errorHandler;

-(void)requestChangeStatusWithID:(NSNumber*)issueIdNumber
                        toStatus:(NSString*)stringStatus
        andViewControllerHandler:(void (^)(NSString *stringAnswer, Issue *issue))viewControllerHandler // e.g. user is not logined
             andErrorHandler:(void(^)(NSError *error)) errorHandler;


@end


#endif
