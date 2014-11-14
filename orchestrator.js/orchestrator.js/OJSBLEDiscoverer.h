//
//  OJSBLEDiscoverer.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 6.11.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface OJSBLEDiscoverer : NSObject<CLLocationManagerDelegate>


- (void) scan;

@end
