//
//  Person.m
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import "User.h"

@interface User()

@end


@implementation User



-(instancetype)initWithName:(NSString *)name andLogin:(NSString *)login andPass:(NSString *)pass andEmail:(NSString *)email
{
    if(self = [super init])
    {
        _name=name;
        _login=login;
        _password=pass;
        _email=email;
    }
    return self;
}

-(instancetype)initWitDictionary:(NSDictionary <NSString*, NSString*>*)dic
{
    if(self=[super init])
    {
        self.login = [dic objectForKey:@"LOGIN"];
        self.name = [dic objectForKey:@"NAME"];
        self.email = [dic objectForKey:@"EMAIL"];
        self.password = [dic objectForKey:@"PASSWORD"];
        self.userId = [[dic objectForKey:@"ID"] integerValue];
        self.role = [[User userStringRoles] indexOfObject:[dic objectForKey:@"ROLE_ID"]];
        self.avatar = [dic objectForKey:@"AVATAR"];
        if ([self.avatar isEqual:[NSNull null]])
        {
            self.avatar = @"defaultUser";
        }
    }
    return self;
}

+(NSArray <NSString*>*)userStringRoles
{
    static NSArray *stringRoles = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stringRoles = @[@"ADMIN", @"MANAGER", @"USER", @"SUBSCRIBER"];
    });
    return stringRoles;
}


-(NSString*)stringRole
{
    return [[User userStringRoles] objectAtIndex:self.role];
}





-(NSDictionary <NSString*, NSString*> *)puckToDictionary
{
    NSMutableDictionary <NSString*, NSString*> *dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:self.login forKey:@"LOGIN"];
    [dic setObject:self.name forKey:@"NAME"];
    [dic setObject:self.email forKey:@"EMAIL"];
    [dic setObject:self.password forKey:@"PASSWORD"];
// we don't need these fields for sign up request
//     [dic setObject:[[User userStringRoles] objectAtIndex:self.role] forKey:@"ROLE_ID"];
//    [dic setObject:[NSString stringWithFormat:@"%d", self.userId] forKey:@"ID"];
    return dic;
}

@end
