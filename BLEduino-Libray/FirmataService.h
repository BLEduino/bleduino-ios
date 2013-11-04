//
//  FirmataService.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BleService.h"

@interface FirmataService : BleService

/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
extern NSString *kFirmataServiceUUIDString;
//8C6B1ED1-A312-681D-025B-0032C0D16A2D  Firmata Service

extern NSString *kFirmataCommandCharacteristicUUIDString;
//8C6B2551-A312-681D-025B-0032C0D16A2D  Firmata Command Characteristic
@end
