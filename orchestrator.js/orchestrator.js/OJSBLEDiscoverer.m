//
//  OJSBLEDiscoverer.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 6.11.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import "OJSBLEDiscoverer.h"


@interface OJSBLEDiscoverer()

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;


@end


@implementation OJSBLEDiscoverer


- (id) init {
    
    self = [super init];
    if (self) {
        
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        // iBeacon
        // 19d5f76a-fd04-5aa3-b16e-e93277163af6
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"717f860e-f0e6-4c93-a4e3-cc724d27e05e"];
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"GEMTot USB"];
    }
    
    return self;
}

- (void) scan
{
    NSLog(@"scan.. ");
    [_locationManager startMonitoringForRegion:_beaconRegion];
    NSLog(@"scan.. 1");
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Beacon Found");
    [_locationManager startRangingBeaconsInRegion:_beaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Left from region");
    [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
}



-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
    
    
    NSLog(@"foo 1");
    
    //self.UUID.text = beacon.proximityUUID.UUIDString;
    
    NSLog(beacon.proximityUUID.UUIDString);
    
    
    if (beacon.proximity == CLProximityUnknown) {
        //_distanceLabel.text = @"Unknown Proximity";
        //[self.view setBackgroundColor:[UIColor blackColor]];
    } else if (beacon.proximity == CLProximityImmediate) {
        //_distanceLabel.text = @"Immediate";
        //[self.view setBackgroundColor:[UIColor redColor]];
    } else if (beacon.proximity == CLProximityNear) {
        //_distanceLabel.text = @"Near";
        //[self.view setBackgroundColor:[UIColor orangeColor]];
    } else if (beacon.proximity == CLProximityFar) {
        //_distanceLabel.text = @"Far";
        //[self.view setBackgroundColor:[UIColor blueColor]];
    }
    
}



- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [_locationManager startRangingBeaconsInRegion:_beaconRegion];
}





@end
