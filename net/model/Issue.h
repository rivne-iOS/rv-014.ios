//
//  BPPoint.h
//  net
//
//  Created by Admin on 05.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IssueHistory.h"


typedef enum : NSUInteger {
    NEW,
    APPROVED,
    CANCEL,
    TO_RESOLVE,
    RESOLVED,
} Status;


@interface Issue : NSObject

@property(nonatomic, readonly)NSString *stringStatus;

@property(nonatomic)NSUInteger pointId;
@property(nonatomic)Status statusEnum;
@property(strong, nonatomic)NSString *pDescription;
@property(strong, nonatomic)NSString *mapInfo;
@property(strong, nonatomic)NSString *name;
@property(strong, nonatomic)NSArray *pointHistory; // of IssueHistory

//{
//    "ATTACHMENTS": "../img/attacments/incident01272.png",
//    "CATEGORY_ID": "1",
//    "DESCRIPTION": "Some big description to this issue",
//    "ID": 2,
//    "MAP_POINTER": "LatLng(50.622647, 26.265234)",
//    "NAME": "Remove graffiti please",
//    "PRIORITY_ID": 1,
//    "STATUS": "TO_RESOLVE"
//},

//@property (strong, nonatomic) NSString *ATTACHMENTS;
//@property (strong, nonatomic) NSString *CATEGORY_ID;
//@property (strong, nonatomic) NSString *DESCRIPTION;
//@property (strong, nonatomic) NSArray *HISTORY;
//@property (strong, nonatomic) NSNumber *ID;
//@property (strong, nonatomic) NSString *MAP_POINTER;
//@property (strong, nonatomic) NSString *NAME;
//@property (strong, nonatomic) NSNumber *PRIORITY_ID;
//@property (strong, nonatomic) NSString *STATUS;

@property (strong, nonatomic) NSNumber *issueId;
@property (strong, nonatomic) NSString *attachments;
@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString *issueDescription;
@property (strong, nonatomic) NSArray *history;
@property (strong, nonatomic) NSString *mapPointer;
//@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *priorityId;
@property (strong, nonatomic) NSString *status;


+(NSArray*)stringStatusesArray;
-(instancetype)initWithDictionary:(NSDictionary *)issueDictionary;
-(double)getLongitude;
-(double)getLatitude;

@end
