//
//  NetworkDataSorce.m
//  net
//
//  Created by Admin on 10.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import "NetworkDataSorce.h"
#import "HTTPConnector.h"
#import "User.h"
#import "Issue.h"
#import "Parser.h"



@implementation NetworkDataSorce


-(void)requestUsers:(void (^)(NSArray * stringPers))viewControllerHandler withErrorHandler:(void(^)(NSError *error)) errorHandler
{
    HTTPConnector *wizard = [[HTTPConnector alloc] init];
    [wizard requestUsers:^(NSData * data, NSError *error)
    {
        if (data.length > 0 && error == nil)
        {
            NSArray *arrOfPers = [Parser parseDataToArrayOfPersons:data];
            NSMutableArray *arrOfStringPers = [[NSMutableArray alloc] init];
            for (User *p in arrOfPers)
            {
                [arrOfStringPers addObject: [[p description] stringByAppendingString:@"\n\n"]];
            }

            NSLog(@"Created arrOfStringPers. First Pers:%@", arrOfStringPers[0]);
            
            viewControllerHandler(arrOfStringPers);
            
        }
        else if (error !=  nil)
        {
            errorHandler(error);
        }

    }];
}


-(void)requestLogInWithUser:(NSString*)user
                    andPass:(NSString*)pass
   andViewControllerHandler:(void (^)(User *resPerson))viewControllerHandler
            andErrorHandler:(void(^)(NSError *error)) errorHandler;
{
    HTTPConnector *wizard = [[HTTPConnector alloc] init];
    [wizard requestLogInWithUser:user andPass:pass andDataSorceHandler:^(NSData *data, NSError *error) {
        if(data.length >0 && error == nil)
        {
            viewControllerHandler([Parser parseDataToPerson:data]);
        }
}];
}


@end
