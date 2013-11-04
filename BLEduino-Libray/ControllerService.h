//
//  ControllerService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BleService.h"

@interface ControllerService : BleService

/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString *kControllerServiceUUIDString;
//8C6BF001-A312-681D-025B-0032C0D16A2D  Controller Service

extern NSString *kButtonActionCharacteristicUUIDString;
//8C6BD00D-A312-681D-025B-0032C0D16A2D  Button Action Characteristic
@end
