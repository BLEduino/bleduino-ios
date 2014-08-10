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
@property BOOL isDistanceAlert;
@property BOOL bleduinoIsCloser;
@property BOOL bleduinoIsFarther;
@end
