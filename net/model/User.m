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

+(NSArray*)BPPersonStringRoles
{
    return @[@"ADMIN", @"MANAGER", @"USER", @"SUBSCRIBER"];
}


//-(instancetype)init
//{
//    if(self = [super init])
//    {
//        _stringRoles = [[NSArray alloc] initWithObjects:@"ADMIN", @"MANAGER", @"USER", @"SUBSCRIBER", nil];
//    }
//    return self;
//}


-(NSString*)description
{
    return [NSString stringWithFormat:@"I am %@, my name is %@, email - %@, role - %@", self.login, self.name, self.email, [[User BPPersonStringRoles] objectAtIndex:self.role]];
}

@end
