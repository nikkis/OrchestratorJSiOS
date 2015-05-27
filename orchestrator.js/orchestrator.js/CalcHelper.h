//
//  CalcHelper.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 27.5.2015.
//  Copyright (c) 2015 Niko Mäkitalo. All rights reserved.
//


// .h file
@interface MovingAverage : NSObject

@property (readonly, nonatomic) float movingAverage;
@property (readonly, nonatomic) float cumulativeAverage;

- (id)initWithPeriod:(NSUInteger)period;
- (void)addDatum:(NSNumber *)datum;

@end

