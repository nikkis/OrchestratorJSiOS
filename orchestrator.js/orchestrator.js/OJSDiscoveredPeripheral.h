//
//  OJSConnectedPeripheral.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 20.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
//#import "SERVICES.h"

@interface OJSDiscoveredPeripheral : NSObject

@property NSString *deviceIdentity;
@property NSString *btUUID;


@property CBPeripheral *peripheral;

@property CBMutableCharacteristic *transferCharacteristic;
@property CBMutableCharacteristic *responseCharacteristic;

-(void)pipiT: (CBMutableCharacteristic*) tc;
-(void)pipiR: (CBMutableCharacteristic*) rc;

@end



@implementation OJSDiscoveredPeripheral

- (id) init: (NSString*) deviceIdentity_ : (NSString*) btUUID_ : (CBPeripheral *) peripheral_
{
    self = [super init];
    if (self) {
//        transferCharacteristic = [NSM];
        self.peripheral = peripheral_;
        self.btUUID = btUUID_;
        self.deviceIdentity = deviceIdentity_;
    }
    return self;
}


-(void)pipiT: (CBMutableCharacteristic*) tc
{
    self.transferCharacteristic = tc;
}

-(void)pipiR: (CBMutableCharacteristic*) rc
{
    self.responseCharacteristic = rc;
}


@end