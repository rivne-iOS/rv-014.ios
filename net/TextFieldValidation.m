//
//  TextFieldValidation.m
//  net
//
//  Created by Admin on 17.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//


#import "TextFieldValidation.h"

@interface TextFieldValidation()


@end

@implementation TextFieldValidation



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

@end
