//
//  BPParser.m
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//


#import "Parser.h"

@interface Parser()

+(NSUInteger)stringPersonRoleToUInteger:(NSString*) str;

@end


@implementation Parser


+(User*)parseDataToUser:(NSData*)data
{
    NSDictionary *PersonDic = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
    NSLog(@"%@", PersonDic);
    return [Parser parseDictionaryToUser:PersonDic];
}

+(NSArray*)parseDataToArrayOfUsers:(NSData *)data
{
    NSError *err; //we might have problems here, so let's check

    id users = [NSJSONSerialization JSONObjectWithData:data
                                                  options:0
                                                    error:NULL];
    if(err!=nil)
        return nil; //:)
    // TODO: add nserror or some like this (when func returns nil)
    
    //we have a few persons
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(id oneUser in users)
    {
        if(![oneUser isKindOfClass:[NSDictionary class]])
        {
            // a is not a dictionary too. so fail
            NSLog(@"// a is not a dictionary too. so fail");
            return nil;
        }
       [arr addObject:[Parser parseDictionaryToUser:oneUser]];
    }
    return arr;
    
}

+(User*)parseDictionaryToUser:(NSDictionary*)dic
{
    User *pers = [[User alloc] init];
    
    if ([dic count] == 1)
        return nil;
    
    pers.userId = [[[dic objectForKey:@"ID"] description] integerValue];
    pers.login = [dic objectForKey:@"LOGIN"];
    pers.name = [dic objectForKey:@"NAME"];
    pers.email = [dic objectForKey:@"EMAIL"];
    pers.role = [Parser stringPersonRoleToUInteger: [[dic objectForKey:@"ROLE_ID"] description]];
    
    return pers;
}

+(NSData*)parseUserToData:(User*)user
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                 user.name, @"name",
                                 user.login, @"login",
                                 user.password, @"password",
                                 user.email, @"email",
                                nil];
    
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&err];
    return postData;

}

+(NSData*)parseToDataWithLogIn:(NSString*)login andPassword:(NSString*)password
{
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                         login, @"login",
                         password, @"password", nil];
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&err];
    return postData;

}


+(NSUInteger)stringPersonRoleToUInteger:(NSString*) str
{
    NSArray *tempArr = [User UserStringRoles];
    for (NSUInteger a=0; a<[tempArr count]; ++a)
    {
        if([str isEqualToString:tempArr[a]])
        {
            return a;
        }
    }
    return -1;
}




+(Issue*)parseDataToPoint:(NSData*)data
{
    NSDictionary *PointDic = [NSJSONSerialization JSONObjectWithData:data
                                                              options:0
                                                                error:NULL];
    return [Parser parseDictionaryToPoint:PointDic];
}

+(Issue*)parseDictionaryToPoint:(NSDictionary*)dic
{
    Issue *point = [[Issue alloc] init];
    
    // TODO тупо по аналогии з персоном

    
    return point;
}



@end
