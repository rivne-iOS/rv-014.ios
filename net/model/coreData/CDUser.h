//
//  CDUser.h
//  
//
//  Created by Admin on 25.03.16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDUser : NSManagedObject

+(CDUser*)syncFromUser:(User*)user withContext:(NSManagedObjectContext*)context;
+(void)syncFromUsers:(NSArray<User*>*)users withContext:(NSManagedObjectContext*)context;



@end

NS_ASSUME_NONNULL_END

#import "CDUser+CoreDataProperties.h"
