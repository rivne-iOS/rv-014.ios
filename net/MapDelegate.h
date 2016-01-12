//
//  MapDelegate.h
//  net
//
//  Created by Admin on 12.01.16.
//  Copyright (c) 2016 Admin. All rights reserved.
//

#ifndef net_MapDelegate_h
#define net_MapDelegate_h
#import "BPPerson.h"


@protocol  MapDelegate <NSObject>

-(void)updateMapPerson(BPPerson *pers);

@end

#endif
