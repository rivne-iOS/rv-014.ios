//
//  TextFieldValidation.h
//  net
//
//  Created by Admin on 17.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TextFieldValidation : NSObject

@property(strong, nonatomic)NSArray *fields; // arr of fields to validate

-(BOOL)isFilled;


@end
