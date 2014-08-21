//
//  DistanceAlert.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 7/18/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProximityAlert : NSObject
@property NSInteger distance;
@property NSString *message;
@property double lastShow;
@property BOOL isDistanceAlert;
@property (readonly, getter = isProximityAlertReady) BOOL isReadyToShow;
@property BOOL bleduinoIsCloser;
@property BOOL bleduinoIsFarther;
@end
