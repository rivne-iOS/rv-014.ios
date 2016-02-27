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
-(void)requestCategories:(void(^)(NSData *data, NSError *error))dataSorceHandler;
-(void)requestImageWithName:(NSString*)name andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler;

-(void)requestCommentWithID:(NSString*)strID andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler;
-(void)requestSendNewCommentWithIssueID:(NSString*)strID
                             andPosData:(NSData*)data
                    andDatasorceHandler:(void(^)(NSData* data, NSError *error))dataSorceHandler;


-(void)requestLogInWithData:(NSData*)data
        andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler;

-(void)requestSingUpWithData:(NSData*)data
        andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler;

-(void)requestSignOutWithHandler:(void (^)(NSData *data, NSError *error))dataSorceHandler;

-(void)requestChangeStatusWithStringIssueID:(NSString*)strindIssueID
                                   toStatus:(NSString*)stringStatus
                                   withData:(NSData*)data
         andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler;

@end
