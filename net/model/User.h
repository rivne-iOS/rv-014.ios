//
//  Person.h
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ADMIN,
    MANAGER,
    USER,
    SUBSCRIBER
} Role;




@interface User : NSObject

@property(nonatomic)NSUInteger userId;
@property(strong, nonatomic)NSString *login;
@property(strong, nonatomic)NSString *name;
@property(strong, nonatomic)NSString *email;
@property(nonatomic) Role role;


+(NSArray*)UserStringRoles;

@end
