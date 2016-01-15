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

@protocol DataSorceProtocol <NSObject>

-(void)requestUsers:(void (^)(NSArray * stringPers))viewControllerHandler withErrorHandler:(void(^)(NSError *error)) errorHandler;

-(void)requestLogInWithUser:(NSString*)user
                    andPass:(NSString*)pass
   andViewControllerHandler:(void (^)(User *resPerson))viewControllerHandler
            andErrorHandler:(void(^)(NSError *error)) errorHandler;

-(void)requestSingUpWithUser:(User*)user
   andViewControllerHandler:(void (^)(User *resPerson))viewControllerHandler
            andErrorHandler:(void(^)(NSError *error)) errorHandler;


@end


#endif
