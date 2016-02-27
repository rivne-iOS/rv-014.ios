//
//  AvatarView.m
//  net
//
//  Created by Admin on 19.02.16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "AvatarView.h"

@implementation AvatarView


-(void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
}

-(void)awakeFromNib
{
    [self setup];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

-(void)setImage:(UIImage *)image
{
    _image = image;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat height = self.bounds.size.height;
    CGFloat width =  self.bounds.size.width;
    
    CGRect circleRect;
    CGPoint centre;
    
    if(width > height)
    {
        x = (width - height) / 2;
        y = 0;
        width = height;
    }
    else
    {
        x = 0;
        y = (height - width) / 2;
        height = width;
    }
    circleRect = CGRectMake(x, y, width, height);
    centre = CGPointMake(x + width/2, y+ height/2);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [[UIColor whiteColor] setStroke];
    [path stroke];
    [path addClip];
    [self.image drawInRect:circleRect];

    
    // just for learning  - alternative c-function approach
//    CGContextRef context  = UIGraphicsGetCurrentContext();
//    CGContextBeginPath(context);
//    CGContextAddArc(context, centre.x, centre.y, height/2, 0, 2*M_PI, 0);
//    CGContextClosePath(context);
//    CGContextClip(context);
//    [self.image drawInRect:circleRect];
//    UIGraphicsEndImageContext();
    
}

@end
