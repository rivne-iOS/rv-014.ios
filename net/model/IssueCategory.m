//
//  IssueCategory.m
//  
//
//  Created by Admin on 27/01/16.
//
//

#import "IssueCategory.h"

@implementation IssueCategory

-(instancetype)initWithDictionary:(NSDictionary *)categoryDictionary
{
    self = [super init];
    
    NSString *camelStyleKey;
    if (self) {
        //Loop method
        for (NSString* key in categoryDictionary) {
            camelStyleKey = [self fromConstFontStyleToCamel:key];
            if ([camelStyleKey isEqualToString:@"id"])
                camelStyleKey = @"categoryId";
            [self setValue:[categoryDictionary valueForKey:key] forKey:camelStyleKey];
        }
        // Instead of Loop method you can also use:
        // [self setValuesForKeysWithDictionary:JSONDictionary];
    }
    return self;
}

-(NSString *)fromConstFontStyleToCamel:(NSString *)inputString
{
    //Example PRIORITY_ID -> priorityId
    
    BOOL underscoreFound = NO;
    unichar letter;
    NSString *resultString = [[NSString alloc] init];
    NSString *stringTypeLetter;
    
    for (int i = 0; i < inputString.length; ++i){
        letter = [inputString characterAtIndex:i];
        stringTypeLetter = [NSString stringWithCharacters:&letter length:1];
        
        if ([stringTypeLetter isEqualToString:@"_"]){
            underscoreFound = YES;
            continue;
        }
        if (underscoreFound == NO)
            resultString = [resultString stringByAppendingString:[stringTypeLetter lowercaseString]];
        else {
            resultString = [resultString stringByAppendingString:stringTypeLetter];
            underscoreFound = NO;
        }
    }
    
    return resultString;
}


@end
