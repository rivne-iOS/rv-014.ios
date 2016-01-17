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

+(NSArray*)BPPointStringStatuses
{
    return @[@"APPREVED", @"TO_RESOLVE", @"RESOLVED"];
}

-(instancetype)initWithDictionary:(NSDictionary *)issueDictionary
{
    self = [super init];
    if (self) {
            //Loop method
            for (NSString* key in issueDictionary) {
                [self setValue:[issueDictionary valueForKey:key] forKey:key];
            }
            // Instead of Loop method you can also use:
            // [self setValuesForKeysWithDictionary:JSONDictionary];
    }
    return self;
}

-(double)getLongitude
{
    NSString *mapPointer = [self.MAP_POINTER copy];
    NSString *resultedString = [self findMatchedStringByPattern:@"[1234567890.]+" andString:mapPointer];
    mapPointer = [mapPointer stringByReplacingOccurrencesOfString:resultedString withString:@""];
    return [[self findMatchedStringByPattern:@"[1234567890.]+" andString:mapPointer] doubleValue];
}

-(double)getLatitude
{
    return [[self findMatchedStringByPattern:@"[1234567890.]+" andString:self.MAP_POINTER] doubleValue];
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
        NSLog(@"match: %@", matchText);
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



@end
