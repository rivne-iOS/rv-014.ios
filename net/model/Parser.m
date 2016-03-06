//
//  BPParser.m
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//


#import "Parser.h"

@interface Parser()


@end


@implementation Parser


+(NSString*)parseAnswer:(NSData*)data andReturnObjectForKey:(NSString*)stringKey
{
    NSDictionary *answerDic = [NSJSONSerialization JSONObjectWithData:data
                                                              options:0
                                                                error:NULL];
    NSLog(@"Log out:\n%@", answerDic);
    
    return [answerDic objectForKey:stringKey];
}

@end
