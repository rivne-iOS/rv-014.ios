//
//  CDUser.m
//  
//
//  Created by Admin on 25.03.16.
//
//

#import "CDUser.h"
#import "NetworkDataSorce.h"

@interface CDUser()

@end

@implementation CDUser


// isn't nice...
+(NetworkDataSorce*)networkDataSorce
{
    static NetworkDataSorce *_networkDataSorce = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _networkDataSorce = [[NetworkDataSorce alloc] init];
    });
    return _networkDataSorce;
}



+(CDUser*)syncFromUser:(User*)user withContext:(NSManagedObjectContext*)context
{
    CDUser *cdUser = nil;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId = @%", user.userId];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CDUser"];
    request.predicate = predicate;
    NSError *error= nil;
    NSArray <CDUser*> *cdUsers = [context executeFetchRequest:request error:&error];
    
    if(cdUsers == nil || error!=nil)
    {
        // request error
    }
    else if ([cdUsers count]>1)
    {
        // dublicate error
    }
    else if ([cdUsers count]<1)
    {
        // add new user
        cdUser = [NSEntityDescription insertNewObjectForEntityForName:@"CDUser"
                                      inManagedObjectContext:context];
        [CDUser updateAvatarforCDUser:cdUser];
    }
    else
    {
        // return user and update info (if needed)
        cdUser = [cdUsers firstObject];
        
        // update fields that can be changed
        if(![cdUser.name isEqualToString:user.name])
            cdUser.name = user.name;
        if(![cdUser.email isEqualToString:user.email])
            cdUser.email = user.email;
        if(![cdUser.avatarString isEqualToString:user.avatar])
        {
            cdUser.avatarString = user.avatar;
            [CDUser updateAvatarforCDUser:cdUser];
        }
        
    }
    
    return cdUser;
}


+(void)updateAvatarforCDUser:(CDUser*)cdUser
{
    [[CDUser networkDataSorce] requestImageWithName:cdUser.avatarString
                                         andHandler:^(UIImage *image, NSError *error) {
         if (image!=nil)
         {
             NSUInteger pos = cdUser.avatarString.length-3;
             NSRange range = NSMakeRange(pos, 3);
             NSString *fileExtension = [cdUser.avatarString substringWithRange:range];
             if ([fileExtension isEqualToString:@"png"])
             {
                 cdUser.avatarData = UIImagePNGRepresentation(image);
             }
             else if ([fileExtension isEqualToString:@"jpg"])
             {
                 cdUser.avatarData = UIImageJPEGRepresentation(image, 1.0);
             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIAlertView *alert = [[UIAlertView alloc] init];
                     alert.title = @"Error in updateAvatarforCDUser";
                     alert.message = [NSString stringWithFormat:@"file name is - %@", cdUser.avatarString];
                     [alert show];
                 });
             }
             
         }
        }];
}



+(void)suncFromUsers:(NSArray<User*>*)users withContext:(NSManagedObjectContext*)context
{
    for (User * user in users)
    {
        [CDUser syncFromUser:user withContext:context];
    }
    
}

@end
