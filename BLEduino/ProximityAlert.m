//
//  DistanceAlert.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 7/18/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "ProximityAlert.h"

@implementation ProximityAlert

- (BOOL)isProximityAlertReady
{
    double now = CACurrentMediaTime();
    return ((now - self.lastShow) >= 5.0);
}
@end
