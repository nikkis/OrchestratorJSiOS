//
//  CalcHelper.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 27.5.2015.
//  Copyright (c) 2015 Niko Mäkitalo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CalcHelper.h"

// .m file
@interface MovingAverage ()
@property (strong, nonatomic) NSMutableArray *queue;
@property (assign, nonatomic) NSUInteger period;
@property (assign, nonatomic) NSUInteger count;
@property (assign, nonatomic) float movingAverage;
@property (assign, nonatomic) float cumulativeAverage;
@end

@implementation MovingAverage

- (id)initWithPeriod:(NSUInteger)period {
    
    self = [self init];
    if (self) {
        _period = period;
        // with arc
        _queue = [NSMutableArray array];
        // without arc
        //_queue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addDatum:(NSNumber *)datum {
    
    [self.queue insertObject:datum atIndex:0];
    
    float removed = 0;
    float datumf = [datum floatValue];
    
    if (self.queue.count > self.period) {
        removed = [[self.queue lastObject] floatValue];
        [self.queue removeLastObject];
    }
    
    self.movingAverage = self.movingAverage - (removed / self.period) + (datumf / self.period);
    
    // compute the cumulative average
    self.cumulativeAverage = self.cumulativeAverage + (datumf - self.cumulativeAverage) / ++self.count;
}

// if non-ARC
- (void)dealloc {
    //[_queue release];
    //[super dealloc];
}

@end