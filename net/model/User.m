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

+(NSArray*)UserStringRoles
{
    return @[@"ADMIN", @"MANAGER", @"USER", @"SUBSCRIBER"];
}


-(NSString*)description
{
    return [NSString stringWithFormat:@"I am %@, my name is %@, email - %@, role - %@", self.login, self.name, self.email, [[User UserStringRoles] objectAtIndex:self.role]];
}

@end
