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
@property(strong, nonatomic)NSString *password;
@property(strong, nonatomic)NSString *avatar;
@property(strong, nonatomic, readonly)NSString *stringRole; // just getter! with no iVar

@property(nonatomic) Role role;



-(instancetype)initWithName:(NSString*)name
                   andLogin:(NSString*)login
                    andPass:(NSString*)pass
                   andEmail:(NSString*)email;

-(instancetype)initWitDictionary:(NSDictionary <NSString*, NSString*>*)dic;

-(NSDictionary <NSString*, NSString*> *)puckToDictionary;

-(NSString*)stringRole;
@end
