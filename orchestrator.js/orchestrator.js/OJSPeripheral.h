//
//  OJSiBeacon.h
//  orchestrator.js
//
//  Created by Niko on 7.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//


// Used for executing commands AND for advertising (iBeacon)


#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

#import "SERVICES.h"

#import "OJSActionController.h"

@interface OJSPeripheral : NSObject<CBPeripheralManagerDelegate>

- (BOOL) initBLEPeripheral: (OJSActionController *) actionCtrl;
- (void) stopiBeacon;



@end