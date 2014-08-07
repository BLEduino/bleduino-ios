//
//  ConsoleEntries.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 7/22/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConsoleEntries : NSObject
@property NSString *text;
@property NSDate *time;
@property BOOL isBLEduino;
- (NSString *)timeString;
@end
