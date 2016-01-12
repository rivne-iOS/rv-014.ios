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


+(User*)parseDataToPerson:(NSData*)data
{
    NSDictionary *PersonDic = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
    return [Parser parseDictionaryToPerSon:PersonDic];
}



+(NSArray*)parseDataToArrayOfPersons:(NSData *)data
{
    id fewPersonDic = [NSJSONSerialization JSONObjectWithData:data
                                                              options:0
                                                                error:NULL];
    NSError *err; //we might have problems here, so let's check
    
    if(err!=nil)
        return nil; //:)
    
    if([fewPersonDic isKindOfClass:[NSDictionary class]])
    {
        //so we have one preson
        NSLog(@"//so we have one preson");
        return [NSArray arrayWithObject:[Parser parseDictionaryToPerSon:fewPersonDic]];
    }
    else
    {
        //we have a few persons
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        NSLog(@"//we have a few persons");
        for(id mustBeDic in fewPersonDic)
        {
            if(![mustBeDic isKindOfClass:[NSDictionary class]])
            {
                // a is not a dictionary too. so fail
                NSLog(@"// a is not a dictionary too. so fail");
                return nil;
            }
           [arr addObject:[Parser parseDictionaryToPerSon:mustBeDic]];
        }
        return arr;
    }
}




+(User*)parseDictionaryToPerSon:(NSDictionary*)dic
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

+(NSUInteger)stringPersonRoleToUInteger:(NSString*) str
{
    NSArray *tempArr = [User BPPersonStringRoles];
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
