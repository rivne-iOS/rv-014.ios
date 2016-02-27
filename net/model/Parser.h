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


+(NSString*)parseAnswer:(NSData*)data andReturnObjectForKey:(NSString*)stringKey;


@end
