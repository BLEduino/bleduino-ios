//
//  BDQueue.m
//  BLEduino
//
//  Created by Ramon Gonzalez on 8/6/14.
//  Copyright (c) 2014 Kytelabs. All rights reserved.
//

#import "BDQueue.h"

@interface BDQueue ()
@property (strong) NSMutableArray *queue;
@end

@implementation BDQueue

+ (instancetype)queue
{
    return [[BDQueue alloc] initWithCapacity:100];
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    if (self = [super init])
    {
        self.queue = [[NSMutableArray alloc] initWithCapacity:capacity];
    }
    return self;
}

- (void)enqueue:(id)object
{
    [self.queue addObject:object];
}

- (id)dequeue
{
    id headObject = [self.queue firstObject];
    if (headObject != nil)
    {
        [self.queue removeObjectAtIndex:0];
    }
    
    return headObject;
}

@end
