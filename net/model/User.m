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
    }
    return self;
}

+(NSArray*)userStringRoles
{
    return @[@"ADMIN", @"MANAGER", @"USER", @"SUBSCRIBER"];
}




-(NSString*)description
{
    return [NSString stringWithFormat:@"I am %@, my name is %@, email - %@, role - %@", self.login, self.name, self.email, [[User userStringRoles] objectAtIndex:self.role]];
}

-(NSDictionary <NSString*, NSString*> *)puckToDictionary
{
    NSMutableDictionary <NSString*, NSString*> *dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:self.login forKey:@"LOGIN"];
    [dic setObject:self.name forKey:@"NAME"];
    [dic setObject:self.email forKey:@"EMAIL"];
    [dic setObject:self.password forKey:@"PASSWORD"];
    [dic setObject:[[User userStringRoles] objectAtIndex:self.role] forKey:@"ROLE_ID"];
    [dic setObject:[NSString stringWithFormat:@"%lu", self.userId] forKey:@"ID"];
    return dic;
}

@end
