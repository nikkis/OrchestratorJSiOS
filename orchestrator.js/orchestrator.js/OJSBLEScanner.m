//
//  OJSBLEScanner.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 12.11.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import "OJSBLEScanner.h"

@interface OJSBLEScanner()

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableData *data;

@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic *responseCharacteristic;


@property NSMutableArray *participantServiceIDs;





@end

@implementation OJSBLEScanner




-(void)initScan
{
    
    _LOGGING_ON = FALSE;
    
    if(_centralManager == nil) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    _data = [[NSMutableData alloc] init];
    
    _participantServiceIDs = [[NSMutableArray alloc] init];
    
    //_ojs = ojs;
    
    // TODO: fetch from OJS
    _SCAN_ALL = TRUE;
    
    // 5s
    [_participantServiceIDs addObject:[CBUUID UUIDWithString:@"5bf2e050-4730-46de-b6a7-2c8be4d9fa36"]];
    // 6
    [_participantServiceIDs addObject:[CBUUID UUIDWithString:@"717f860e-f0e6-4c93-a4e3-cc724d27e05e"]];
    
    // mac
    [_participantServiceIDs addObject:[CBUUID UUIDWithString:@"FB694B90-F49E-4597-8306-171BBA78F844"]];
    
    // beacon
    [_participantServiceIDs addObject:[CBUUID UUIDWithString:@"8b034f7b-fa9b-540f-acf3-88c0ca70c84f"]];
    
    _scanResults = [[NSMutableDictionary alloc] init];
}




-(void)stopScan
{
    [_centralManager stopScan];
}




- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    // You should test all scenarios
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        // Scan for devices
        
        if(_SCAN_ALL)
        {
            // Scan all device, and ?connect??
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
            [_centralManager scanForPeripheralsWithServices:nil options:options];
        }
        else
        {
            // scan only OJS-known (listed) devices
            [_centralManager scanForPeripheralsWithServices:_participantServiceIDs options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        }
        [self log:@"OJS BLE Scanning started"];
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    
    
    @try {
        
        
        [self log: [NSString stringWithFormat:@"Discovered %@ at %@, with identifier %@", peripheral.name, RSSI, peripheral.identifier]];
        
        
        //NSString *uuid = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
        //NSLog(@"Report this id: %@ with this rssid to ojs: %@", uuid, RSSI);
        
        
        // Currently this works
        NSArray *discoverdDeviceUUID = (NSArray*)[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
        
        if( discoverdDeviceUUID != nil )
        {
            CBUUID *cu = [discoverdDeviceUUID objectAtIndex:0];
            NSString *serviceUUID = cu.UUIDString;
            
            NSMutableArray* tempRes = [_scanResults objectForKey:serviceUUID];
            if( tempRes == nil ) {
                tempRes = [[NSMutableArray alloc] init];
            }
            [tempRes addObject:RSSI];
            [_scanResults setObject:tempRes forKey:serviceUUID];
            
            /*
             // sends result right to OJS
             NSMutableArray *devices = [[NSMutableArray alloc]init];
             [devices addObject:@[tt,(NSNumber*)RSSI]];
             
             NSMutableDictionary* mm = [[NSMutableDictionary alloc]init];
             [mm setObject:devices forKey:@"bt_devices"];
             
             [_ojs sendContextData:mm];
             */
        }
        
    }
    @catch (NSException *exception) {
        // do nothing if digging out device btuuid/RSSI values fails
        NSLog(@"Error in BLE discovery: %@",exception);
    }
}







/*
 
 // From Android iBeacon lib (https://github.com/AltBeacon/android-beacon-library)
 
 protected static double calculateAccuracy(int txPower, double rssi) {
 if (rssi == 0) {
 return -1.0; // if we cannot determine accuracy, return -1.
 }
 
 double ratio = rssi*1.0/txPower;
 if (ratio < 1.0) {
 return Math.pow(ratio,10);
 }
 else {
 double accuracy =  (0.89976)*Math.pow(ratio,7.7095) + 0.111;
 return accuracy;
 }
 }
 
 */


-(void) log: (NSString*) m {
    if(_LOGGING_ON)
        NSLog(@"BLE SCAN: %@",m);
}


@end
