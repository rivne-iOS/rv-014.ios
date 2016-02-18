//
//  IssueCategory.h
//  
//
//  Created by Admin on 27/01/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IssueCategory : NSObject

@property (strong, nonatomic) NSNumber *categoryId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;

-(instancetype)initWithDictionary:(NSDictionary *)categoryDictionary;

@end
