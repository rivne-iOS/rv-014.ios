//
//  IssueCategory.h
//  
//
//  Created by Admin on 27/01/16.
//
//

#import <Foundation/Foundation.h>

@interface IssueCategory : NSObject

@property (strong, nonatomic) NSNumber *categoryId;
@property (strong, nonatomic) NSString *name;

-(instancetype)initWithDictionary:(NSDictionary *)categoryDictionary;

@end
