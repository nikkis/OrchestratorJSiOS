//
//  OJSDeviceCoordinator.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 22.4.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

#import "SERVICES.h"

@interface OJSDeviceCoordinator : NSObject
{
    NSCondition* condition;
}


-(void)test;
-(void)sinneJaTakas;


-(void)initBTLECentral;
-(void)runAction;

@property (strong, nonatomic) NSObject *responseValue;
@property (strong, nonatomic) NSString *responseJSONString;
@property (atomic) BOOL *waitingForMethodcallResponse;

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData *data;


@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic *responseCharacteristic;

@property (strong, nonatomic) CBMutableCharacteristic *testReadCharacteristic;


@end
