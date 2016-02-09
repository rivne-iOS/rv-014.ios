//
//  TextFieldValidation.m
//  net
//
//  Created by Admin on 17.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//


#import "TextFieldValidation.h"



@interface TextFieldValidation()

@property(strong, nonatomic)NSDictionary *fieldsDic;
@property(strong, nonatomic)NSRegularExpression *regexp;

-(NSUInteger)indexOfFieldWithID:(NSString*) strId;

@end

@implementation TextFieldValidation


-(instancetype)init
{
    if(self=[super init])
    {
        _fieldsDic = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"[A-Za-z ]{3,}", @"Full name",
                            @"^[a-zA-Z][a-z0-9_.-]+$", @"User name",
                            @"^[-a-z0-9!#$%&'*+/=?^_`{|}~]+(?:\\.[-a-z0-9!#$%&'*+/=?^_`{|}~]+)*@(?:[a-z0-9]([-a-z0-9]{0,61}[a-z0-9])?\\.)*(?:aero|arpa|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|[a-z][a-z])$", @"Email",
                            @"^[a-zA-Z0-9][a-z0-9_.-]+$", @"Password",
                            nil];
        
    }
    return self;
}



// don't need for now
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
    
    if(res == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention!"
                                                        message:@"Clear fields!"
                                                       delegate:nil
                                              cancelButtonTitle:@"I understood"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    return res;
}



-(BOOL)isValidField:(UITextField*)field
{
    self.regexp = [NSRegularExpression regularExpressionWithPattern:[self.fieldsDic objectForKey:field.restorationIdentifier]
                                                            options:0
                                                              error:nil];
    
    NSString *tempStr = [self.regexp stringByReplacingMatchesInString:field.text
                                                        options:0
                                                          range:NSMakeRange(0, field.text.length)
                                                   withTemplate:@""];
    if(tempStr.length == 0)
        return YES;
    else
    {
        field.backgroundColor = [UIColor redColor];
        return NO;
    }
    
}

-(BOOL)isValidFields
{
    BOOL res=YES;
    
    for (UITextField *field in self.fields)
    {
        [self isValidField:field];
        
    }
    
    
    return res;
}

@end
