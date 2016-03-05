//
//  ChangerBox.m
//  net
//
//  Created by Admin on 05.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "ChangerBox.h"

@implementation ChangerBox

-(instancetype) initWithButton:(UIButton*)button andImage:(UIImageView*)imageView andLabel:(UILabel*)label
{
    if(self = [super init])
    {
        self.button = button;
        self.label = label;
        self.image = imageView;
    }
    return self;
}

@end
