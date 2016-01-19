//
//  BPParser.h
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Issue.h"

@interface Parser : NSObject


+(User*)parseDataToUser:(NSData*)data;
+(User*)parseDictionaryToUser:(NSDictionary*)dic;

+(NSData*)parseUserToData:(User*)user;
+(NSData*)parseToDataWithLogIn:(NSString*)login andPassword:(NSString*)password;


//array of persons
+(NSArray*)parseDataToArrayOfUsers:(NSData*)data;


+(Issue*)parseDataToPoint:(NSData*)data;
+(Issue*)parseDictionaryToPoint:(NSDictionary*)dic;

+(NSString*)parseSignOutAnswer:(NSData*)data;


@end
