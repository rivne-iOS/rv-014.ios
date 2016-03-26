//
//  CurrentItems.m
//  net
//
//  Created by Admin on 14.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CurrentItems.h"
#import "NetworkDataSorce.h"




@interface CurrentItems()

@property(strong, nonatomic) id<DataSorceProtocol> dataSorce;
@property(strong, nonatomic) NSURL* fullURLforUIManagedDocument;

@end

@implementation CurrentItems

// повний шлях у нас використовується при створенні document
// а також при перевірці чи існує такий файл
// тому повний шлях у нас: self.fullURLforUIManagedDocument

// оскільки віддкривання чи стчворення файлу у нас відбувається в блоці
// тому ми не можемо відвразу повернути context
// тому у нас void метод startInitManagedObjextContext
// у випадку коли він вже проініціалізований - він же й вповертається
// якщо ні - поівертається nil, но при цьому запускається відповідний метод (стратування ініціалізації)
// і вже там десь він буде сетатись

-(NSURL*)fullURLforUIManagedDocument
{
    if (_fullURLforUIManagedDocument==nil)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsDir = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSString *documentName = @"BawlDoc";
        _fullURLforUIManagedDocument = [documentsDir URLByAppendingPathComponent:documentName];
    }
    return _fullURLforUIManagedDocument;
}

-(UIManagedDocument*)managedDocument
{
    if(_managedDocument == nil)
    {
        _managedDocument = [[UIManagedDocument alloc] initWithFileURL:self.fullURLforUIManagedDocument];
    }
    return _managedDocument;
}

-(NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext==nil)
       [self startInitManagedObjectcontext];
    return _managedObjectContext;
}

-(void)startInitManagedObjectcontext
{
    // if it already inited - we do nothing
    if (self.managedObjectContext!=nil)
        return;
    
    __weak CurrentItems *weakSelf = self;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.fullURLforUIManagedDocument path]])
    {
        // якщо файл існує
        [self.managedDocument openWithCompletionHandler:^(BOOL success) {
            [weakSelf afterOpenManagedDocument:success];
        }];
    }
    else
    {
        // файл не існує - створюємо
        [self.managedDocument saveToURL:self.fullURLforUIManagedDocument
                       forSaveOperation:UIDocumentSaveForCreating
                      completionHandler:^(BOOL success) {
            [weakSelf afterOpenManagedDocument:success];
        }];
    }
}


-(void)afterOpenManagedDocument:(BOOL)success
{
    BOOL someFail = NO;
    if(success==YES)
    {
        if (self.managedDocument.documentState == UIDocumentStateNormal)
        {
            self.managedObjectContext = self.managedDocument.managedObjectContext;
        }
        else
        {
            someFail = YES;
        }
    }
    else
    {
        someFail = YES;
    }
    
    // check for fail
    if (someFail == YES)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Getting cache info"
                                                        message:@"Fail while loading cache"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(id<DataSorceProtocol>)dataSorce
{
    if(_dataSorce==nil)
        _dataSorce = [[NetworkDataSorce alloc] init];
    return _dataSorce;
}


+(instancetype)sharedItems
{
    static CurrentItems *sharedItems_ = nil;
    static dispatch_once_t token =0;
    dispatch_once(&token, ^{
        sharedItems_ = [[super alloc] initSinleObject];
    });
    
    return sharedItems_;
}

-(instancetype)initSinleObject
{
    if(self = [super init])
    {
        _userImageDelegates = [[NSMutableArray alloc] init];
        _issueImageDelegates = [[NSMutableArray alloc] init];
    }
    return self;
}


-(void)setUser:(User *)user
{
    _user = user;
    NSString *unchangedName = self.user.avatar;
    [self.dataSorce requestImageWithName:self.user.avatar andHandler:^(UIImage *image, NSError *error) {
        if ([unchangedName isEqualToString:self.user.avatar])
        {
            self.userImage = image;
            [self.userImageDelegates makeObjectsPerformSelector:@selector(userImageDidLoad)];
        }
    }];

    
}

-(void)setUser:(User *)user withChangingImageViewBloc:(void(^)()) changinImageView
{
    self.user = user;
    
    NSString *unchangedName = self.user.avatar;
    [self.dataSorce requestImageWithName:self.user.avatar andHandler:^(UIImage *image, NSError *error) {
        if ([unchangedName isEqualToString:self.user.avatar])
        {
            self.userImage = image;
            changinImageView();
        }
    }];
    
}

-(void)setIssue:(Issue *)issue
{
    _issue = issue;
    NSString *unchangedName = self.issue.attachments;
    [self.dataSorce requestImageWithName:self.issue.attachments andHandler:^(UIImage *image, NSError *error) {
        if ([unchangedName isEqualToString:self.issue.attachments])
        {
            self.issueImage = image;
            [self.issueImageDelegates makeObjectsPerformSelector:@selector(issueImageDidLoad)];
        }
    }];
}

-(void)setIssue:(Issue *)issue withChangingImageViewBloc:(void(^)()) changinImageView
{
    self.issue = issue;
    
    NSString *unchangedName = self.issue.attachments;
    [self.dataSorce requestImageWithName:self.issue.attachments andHandler:^(UIImage *image, NSError *error) {
        if ([unchangedName isEqualToString:self.issue.attachments])
        {
            self.issueImage = image;
            changinImageView();
            
        }
    }];
    
}





@end
