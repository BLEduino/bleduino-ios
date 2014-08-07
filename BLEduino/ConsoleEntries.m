//
//  ConsoleEntries.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 7/22/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "ConsoleEntries.h"

@implementation ConsoleEntries
- (NSString *)timeString
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:self.time];
    
    NSInteger hour = [components hour];
    NSString *period = (hour > 11)?@" PM":@" AM";
    NSString *dateFormat = ((hour > 0 && hour < 10) || (hour > 12 && hour < 22))?@"h:mm:ss":@"hh:mm:ss";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    NSString *date = [formatter stringFromDate:self.time];
    date = [date stringByAppendingString:period];
    return date;
}
@end
