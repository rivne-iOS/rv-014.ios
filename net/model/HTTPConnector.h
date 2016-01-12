//
//  BPHTTPWizard.h
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HTTPConnector : NSObject

@property(readonly, nonatomic)NSString* globalURL;
@property(readonly, nonatomic)NSString* allPersURL;
@property(readonly, nonatomic)NSString* allPointsURL;
@property(readonly, nonatomic)NSString* userLogIn;

-(void)requestUsers:(void(^)(NSData *data, NSError *error))dataSorceHandler;
-(void)requestLogInWithUser:(NSString*)user
                    andPass:(NSString*)pass
        andDataSorceHandler:(void(^)(NSData *data, NSError *error))dataSorceHandler;


@end
