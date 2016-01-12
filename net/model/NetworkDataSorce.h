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


@end
