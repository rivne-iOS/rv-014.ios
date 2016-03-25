//
//  CDIssue+CoreDataProperties.h
//  
//
//  Created by Admin on 25.03.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDIssue.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDIssue (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *issueID;
@property (nullable, nonatomic, retain) NSString *imageString;
@property (nullable, nonatomic, retain) NSData *imageData;
@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) NSString *status;

@end

NS_ASSUME_NONNULL_END
