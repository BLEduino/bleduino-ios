//
//  BDQueue.h
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/6/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDQueue : NSObject
- (void)enqueue:(id)object;
- (id)dequeue;
+ (instancetype)queue;
@end
