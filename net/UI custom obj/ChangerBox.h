//
//  ChangerBox.h
//  net
//
//  Created by Admin on 05.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChangerBox : NSObject

@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UIImageView *image;
@property (strong, nonatomic) UILabel *label;

-(instancetype) initWithButton:(UIButton*)button andImage:(UIImageView*)imageView andLabel:(UILabel*)label;

@end
