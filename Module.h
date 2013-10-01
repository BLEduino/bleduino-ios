//
//  Module.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 10/1/13.
//  Copyright (c) 2013 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface Module : NSObject
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) NSString *moduleName;
@property (nonatomic, strong) NSUUID *serviceUUID; 
@end
