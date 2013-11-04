//
//  VehicleMotionService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BleService.h"

@interface VehicleMotionService : BleService

/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString *kVehicleMotionServiceUUIDString;
//8C6B1125-A312-681D-025B-0032C0D16A2D  VehicleMotion Service

extern NSString *kThrottleYawRollPitchCharacteristicUUIDString;
//8C6B9806-A312-681D-025B-0032C0D16A2D  Throttle Yaw Roll Pitch Characteristic

@end


