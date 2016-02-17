//
//  BPPoint.m
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import "Issue.h"

@interface Issue()

-(NSString*)pointHistoryToString;

@end


@implementation Issue

+(NSArray*)stringStatusesArray
{
    return @[@"NEW", @"APPROVED", @"CANCEL", @"TO_RESOLVE", @"RESOLVED"];
}

-(NSString*)stringStatus
{
    return [[Issue stringStatusesArray] objectAtIndex:self.statusEnum];
}

-(instancetype)initWithDictionary:(NSDictionary *)issueDictionary
{
    self = [super init];
    
    NSString *camelStyleKey;
    if (self) {
            //Loop method
            for (NSString* key in issueDictionary) {
                camelStyleKey = [self fromConstFontStyleToCamel:key];
                if ([camelStyleKey isEqualToString:@"id"])
                    camelStyleKey = @"issueId";
                if ([camelStyleKey isEqualToString:@"description"])
                    camelStyleKey = @"issueDescription";
                [self setValue:[issueDictionary valueForKey:key] forKey:camelStyleKey];
            }
            // Instead of Loop method you can also use:
            // [self setValuesForKeysWithDictionary:JSONDictionary];
        if ([self.attachments isEqual:[NSNull null]]) {
            self.attachments = @"defaultIssue";
        }
    }
    return self;
}

-(double)getLongitude
{
    NSString *mapPointer = [self.mapPointer copy];
    NSString *resultedString = [self findMatchedStringByPattern:@"[1234567890.]+" andString:mapPointer];
    mapPointer = [mapPointer stringByReplacingOccurrencesOfString:resultedString withString:@""];
    return [[self findMatchedStringByPattern:@"[1234567890.]+" andString:mapPointer] doubleValue];
}

-(double)getLatitude
{
    return [[self findMatchedStringByPattern:@"[1234567890.]+" andString:self.mapPointer] doubleValue];
}

-(NSString *)findMatchedStringByPattern:(NSString *)inputPattern andString:(NSString *)inputString {
    NSString *searchedString = inputString;
    NSRange  searchedRange = NSMakeRange(0, [searchedString length]);
    NSString *pattern = inputPattern;
    NSError  *error = nil;
    NSString *matchText;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
    NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
    for (NSTextCheckingResult* match in matches) {
        matchText = [searchedString substringWithRange:[match range]];
//        NSLog(@"match: %@", matchText);
        break;
    }
    return matchText;
}

//-(instancetype)init
//{
//    if (self=[super init]) {
//        _stringStatus = [[NSArray alloc] initWithObjects:@"APPREVED", @"TO_RESOLVE", @"RESOLVED", nil];
//    }
//    return self;
//}


-(NSString*)description
{
    return [NSString stringWithFormat:@"This is a point with name - %@, mapInfo - %@, and such history:\n%@", self.name, self.mapInfo, [self pointHistoryToString]];
}


-(NSString*)pointHistoryToString;
{
    NSMutableString *mStr = [[NSMutableString alloc] init];
    
    for (IssueHistory *h in self.pointHistory)
    {
        [mStr appendString:[h description]];
        [mStr appendString:@"\n"];
    }
    
    if(mStr.length !=0)
        [mStr deleteCharactersInRange:NSMakeRange([mStr length]-1,1)];
    
    return mStr;
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
