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


+(User*)parseDataToPerson:(NSData*)data;
+(User*)parseDictionaryToPerSon:(NSDictionary*)dic;


//array of persons
+(NSArray*)parseDataToArrayOfPersons:(NSData*)data;


+(Issue*)parseDataToPoint:(NSData*)data;
+(Issue*)parseDictionaryToPoint:(NSDictionary*)dic;



@end
