//
//  DistanceAlert.h
//  BLEduino
//
//  Created by Valerie Ann Rodriguez on 7/18/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DistanceAlert : NSObject
@property NSInteger distance;
@property NSString *message;
@property BOOL bleduinoIsCloser;
@property BOOL bleduinoIsFarther;
//Streched Goal
//Add sound. 
@end
