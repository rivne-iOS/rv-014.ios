//
//  TextFieldValidation.m
//  net
//
//  Created by Admin on 17.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//


#import "TextFieldValidation.h"



@interface TextFieldValidation()

// -(BOOL)isField:(UITextField*)field HaveID:(NSString*) strId;
-(NSUInteger)indexOfFieldWithID:(NSString*) strId;

@end

@implementation TextFieldValidation

-(NSUInteger)indexOfFieldWithID:(NSString*) strId
{
    __weak NSString *weakStr = strId;
    return [self.fields indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
       if( [((UITextField*)obj).restorationIdentifier isEqualToString:weakStr] )
       {
           *stop = YES;
           return YES;
       }
        return NO;
    }];
}


-(BOOL)isFilled
{
    BOOL res = YES;
    for(UITextField * field in self.fields)
    {
        if((field.text == nil) || [field.text isEqualToString:@""])
        {
            field.backgroundColor = [UIColor redColor];
            res = NO;
        }
    }
    return res;
}


-(BOOL)isValidFields
{
    BOOL res=YES;
    
    for (UITextField *field in self.fields)
    {
        
    }
    
    
    return res;
}

@end
