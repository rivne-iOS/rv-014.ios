//
//  MarkerSpot.m
//  net
//
//  Created by Admin on 20/02/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "MarkerSpot.h"

@implementation MarkerSpot

-(instancetype)initWithMarker:(GMSMarker *)marker visibility:(BOOL)visibility andLocation:(CLLocationCoordinate2D)location
{
    self = [super init];
    
    if (self) {
        self.marker = marker;
        self.visible = visibility;
        self.location = location;
    }
    
    return self;
}

@end
