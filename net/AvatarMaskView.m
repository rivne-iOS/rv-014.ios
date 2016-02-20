//
//  AvatarView.m
//  net
//
//  Created by Admin on 19.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "AvatarMaskView.h"

@implementation AvatarMaskView


-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    [self setup];
    return self;
}


-(void)awakeFromNib
{
    [self setup];
}

-(void)setup
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat height = self.bounds.size.height;
    CGFloat width =  self.bounds.size.width;
    
    CGRect circleRect;
    
    if(width > height)
    {
        CGFloat x = (width - height) / 2;
        CGFloat y = 0;
        circleRect = CGRectMake(x, y, height-1, height-1);
    }
    else
    {
        CGFloat x = 0;
        CGFloat y = (height - width) / 2;
        circleRect = CGRectMake(x, y, width-1, width-1);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextFillRect(context, rect);

    CGContextSetBlendMode(context, kCGBlendModeClear);

    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillEllipseInRect(context, circleRect);

}

@end
