//
//  NetworkDataSorce.h
//  net
//
//  Created by Admin on 10.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataSorceProtocol.h"
#import "User.h"


@interface NetworkDataSorce : NSObject <DataSorceProtocol>

-(void)requestUsers:(void (^)(NSArray * stringPers))viewControllerHandler withErrorHandler:(void(^)(NSError *error)) errorHandler;

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
