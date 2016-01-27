//
//  BPHTTPWizard.h
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HTTPConnector : NSObject


-(void)requestUsers:(void(^)(NSData *data, NSError *error))dataSorceHandler;

-(void)requestLogInWithData:(NSData*)data
        andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler;

-(void)requestSingUpWithData:(NSData*)data
        andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler;

-(void)requestSignOutWithHandler:(void (^)(NSData *data, NSError *error))dataSorceHandler;

-(void)requestChangeStatusWithStringIssueID:(NSString*)strindIssueID
         andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler;

@end
