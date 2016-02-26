//
//  MarkerSpot.h
//  net
//
//  Created by Admin on 20/02/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GoogleMaps;

@interface MarkerSpot : NSObject

@property (strong, nonatomic) GMSMarker *marker;
@property (assign, nonatomic) BOOL visible;
@property (assign, nonatomic) CLLocationCoordinate2D location;

-(instancetype)initWithMarker:(GMSMarker *)marker visibility:(BOOL)visibility andLocation:(CLLocationCoordinate2D)location;

@end
