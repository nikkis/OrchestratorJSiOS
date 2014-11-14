//
//  OJSBLEScanner.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 12.11.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import "OJSConnection.h"

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

@interface OJSBLEScanner : NSObject<CBCentralManagerDelegate>

@property BOOL SCAN_ALL;
@property BOOL LOGGING_ON;

-(void)initScan;
-(void)stopScan;

@property NSMutableDictionary* scanResults;


@end
