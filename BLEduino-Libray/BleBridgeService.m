//
//  BleBridgeService.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 11/3/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import "BleBridgeService.h"

@implementation BleBridgeService

/****************************************************************************/
/*						Service & Characteristics							*/
/****************************************************************************/
NSString *kBleBridgeServiceUUIDString = @"8C6BB1EB-A312-681D-025B-0032C0D16A2D";
NSString *kBridgeRxCharacteristicUUIDString = @"8C6B5778-A312-681D-025B-0032C0D16A2D";
NSString *kBridgeTxCharacteristicUUIDString = @"8C6B454B-A312-681D-025B-0032C0D16A2D";
NSString *kDeviceIDCharacteristicUUIDString = @"8C6BD1D0-A312-681D-025B-0032C0D16A2D";

@end
