//
//  OJSDeviceCoordinator.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 22.4.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//


#import "SocketIOJSONSerialization.h"
#import "OJSConnection.h"

#import "OJSCentral.h"

#import "OJSDiscoveredPeripheral.h"

@interface OJSCentral ()

    @property NSArray *participantInfo;
    @property NSMutableArray *participantServiceIDs;

    @property NSCondition* condition;
    @property OJSConnection *ojsConnection;

    @property NSCondition* connectedToParticipants;
    @property BOOL waitForParticipants;


    // connected peripherals
    @property NSMutableDictionary *connectedPeripherals;

    // discovered peripherals
    @property NSMutableDictionary *discoveredPeripherals;


    @property (strong, nonatomic) NSString *selfDeviceIdentity;
    @property (strong, atomic) OJSSettingsManager* settingsManager;

@property (strong, nonatomic) NSObject *responseValue;
@property (strong, nonatomic) NSString *responseJSONString;
@property (atomic) BOOL *waitingForMethodcallResponse;

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableData *data;

@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic *responseCharacteristic;


@end






@implementation OJSCentral



- (BOOL) initBTLECentral: (OJSConnection*) ojsConnection : (NSArray *) participantInfo
{
    NSLog(@"koo - -5");
//    _centralManager = nil;
    NSLog(@"koo - -4");
    _settingsManager = [[OJSSettingsManager alloc] init];
    _selfDeviceIdentity = [_settingsManager getDeviceIdentity];
    NSLog(@"koo - -3");
    _discoveredPeripherals = [[NSMutableDictionary alloc] init];
    _connectedPeripherals = [[NSMutableDictionary alloc] init];
        NSLog(@"koo - -2");
    _participantInfo = participantInfo;
    
    _participantServiceIDs = [[NSMutableArray alloc] init];
        NSLog(@"koo - -1");
    for( id o in _participantInfo ) {
        NSString *di = [(NSDictionary*)o objectForKey:@"btUUID"];
        NSLog(@"participant: %@", di);
        [_participantServiceIDs addObject:[CBUUID UUIDWithString:di]];
    }
    NSLog(@"koo - 0");
    _ojsConnection = ojsConnection;
    NSLog(@"koo - 1");

    // wait for until initialized ( connected to participants )
    
//    _waitForParticipants = TRUE;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        [self initCentral];
            NSLog(@"koo - 2");

    if([_participantInfo count] == 1 && [_selfDeviceIdentity isEqualToString:[_participantInfo objectAtIndex:0] ]) {
        NSLog(@"I am the one and only participant -> no need to connect");
        return TRUE;
    
    // If other participants, wait for them to connect
    } else {

        NSLog(@"waiting for participants 0");
    
        // wait for response
        [_connectedToParticipants lock];
        _waitForParticipants = TRUE;
        NSLog(@"waiting for participants 1");
        while(_waitForParticipants)
        {
            [_connectedToParticipants wait];
        }
        NSLog(@"waiting for participants 3");
        _waitForParticipants = TRUE;
        [_connectedToParticipants unlock];
    
        NSLog(@"CONNECTED!!!");
    }
    
//    });
    return TRUE;

}






/*
 *
 *      Bluetooth LE Begins here
 *
 */



- (void) initCentral
{
    NSLog(@"initCentral - 0");
    if(_centralManager) {
        _centralManager = nil;
    }
    NSLog(@"initCentral - 1");
    if(_centralManager == nil) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    NSLog(@"initCentral - 2");
    _data = [[NSMutableData alloc] init];
    
    NSLog(@"init central 0");
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // You should test all scenarios
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    NSLog(@"init central 1");
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        // Scan for devices
//        [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        

        [_centralManager scanForPeripheralsWithServices:_participantServiceIDs options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];

        //[_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID], [CBUUID UUIDWithString:@"a9ce4e1f-b18a-4f1d-bc92-4b4ef3775915"], [CBUUID UUIDWithString:@"346240a2-f72e-4a51-a0c2-0c562a716d27"]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];

        
        NSLog(@"Scanning started");
    }
}

/*
-(BOOL) checkDiscoveredPeripheralsForParticipants() {
    
    BOOL retVal = false;
    [_centralManager ];
    
    
    return false;
}
*/

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    
    NSLog(@"Discovered %@ at %@, with identifier %@", peripheral.name, RSSI, peripheral.identifier);
    
    
    @try {
        
//        NSArray *servuuid = (NSArray*)[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
//        NSString *discoverdDeviceUUID = (NSString*)(servuuid[0]);
        NSString *discoverdDeviceUUID = (NSString*)[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
        
        
        NSLog(@"Report this id: %@ with this rssid to ojs: %@", discoverdDeviceUUID, RSSI);
        
        //// TEST SPACE BEGINS
        // report to ojs
        NSLog(@"jaahu 1");
        NSArray *discoverd_device = [NSArray arrayWithObjects:discoverdDeviceUUID, (NSNumber*)RSSI, nil];
        NSArray *bt_devices = [NSArray arrayWithObjects:discoverd_device, nil];
        NSDictionary *proximityData = [NSDictionary dictionaryWithObject:bt_devices forKey:@"bt_devices"];
        [_ojsConnection sendContextData:proximityData];

        NSLog(@"jaahu 2");
        
        //// TEST SPACE ENDS
        
    }
    @catch (NSException *exception) {
        // do nothing if digging out device btuuid/RSSI values fails
    }
    
    
    
    /*
    if(peripheral.name)
    {
        //NSLog(@"saving peripheral for deviceidentity: %@", peripheral.name);
        
        OJSDiscoveredPeripheral *pp = [[OJSDiscoveredPeripheral alloc] init: peripheral.name : @"jaajaa" : peripheral];
        
        [_discoveredPeripherals setObject: pp forKey: peripheral.name];
    }
     */
    
    //if(![_discoveredPeripherals objectForKey:peripheral.name])
    //{
        NSLog(@"saving peripheral for deviceidentity: %@", peripheral.name);
        
        OJSDiscoveredPeripheral *pp = [[OJSDiscoveredPeripheral alloc] init: peripheral.name : @"jaajaa" : peripheral];
        
        [_discoveredPeripherals setObject: pp forKey: peripheral.name];
        
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [_centralManager connectPeripheral:peripheral options:nil];
        
    //}
    
    
    
    
    
    
    
    
    /*
    if (_discoveredPeripheral != peripheral) {
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        _discoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [_centralManager connectPeripheral:peripheral options:nil];
    }
     
    */
    for (CBService *service in peripheral.services) {
        NSLog(@"jaahu 1 %@", service.UUID);
    
    }
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect");
    [self cleanup];
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected");
    
    NSLog(@"Conneted device info %@", peripheral.identifier);
    
    [_connectedPeripherals setObject: peripheral forKey:peripheral.name];
    
    [_centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    [_data setLength:0];
    
    peripheral.delegate = self;
    
    [peripheral discoverServices: _participantServiceIDs];
    
//    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID], [CBUUID UUIDWithString:@"a9ce4e1f-b18a-4f1d-bc92-4b4ef3775915"], [CBUUID UUIDWithString:@"346240a2-f72e-4a51-a0c2-0c562a716d27"] ]];
    
/*
    NSLog(@"wait for connected device is over");
    _waitForParticipants = FALSE;
    [_connectedToParticipants signal];
    [_connectedToParticipants unlock];
*/
}



- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {

    NSLog(@"didDiscoverServices 0");
    NSLog(@"..for peripheral %@ ", peripheral.name);
    
    if (error) {
        NSLog(@"Error in: didDiscoverServices: %@", error);
        [self cleanup];
        return;
    }
    NSLog(@"didDiscoverServices 1");
    for (CBService *service in peripheral.services) {
        
        NSLog(@"bar 0");
        NSLog(@"service uuid %@", service.UUID);
        
        if([[CBUUID UUIDWithString:@"346240a2-f72e-4a51-a0c2-0c562a716d27"] isEqual:service.UUID])
        {
            NSLog(@"discovered device nikkis@iphone5s");
        }

        if([[CBUUID UUIDWithString:@"a9ce4e1f-b18a-4f1d-bc92-4b4ef3775915"] isEqual:service.UUID])
        {
            NSLog(@"discovered device nikkis@iphone");
        }
        
        
        
        
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:RESPONSE_CHARACTERISTIC_UUID]] forService:service];
        
//        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TEST_CHARACTERISTIC_UUID]] forService:service];
    }
    
    

    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:RESPONSE_CHARACTERISTIC_UUID]] forService:service];
    }
    /*
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TEST_CHARACTERISTIC_UUID]] forService:service];
    }*/

    
    // Discover other characteristics
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error in: didDiscoverCharacteristicsForService: %@", error);
        [self cleanup];
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            NSLog(@"TRANSFER CHAR SET");

            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            OJSDiscoveredPeripheral *p = (OJSDiscoveredPeripheral*)[_discoveredPeripherals objectForKey:peripheral.name];
            [p setTransferCharacteristic: (CBMutableCharacteristic *)characteristic];
            [_discoveredPeripherals setObject:p forKey:p.deviceIdentity];
            
            
            _transferCharacteristic = (CBMutableCharacteristic *)characteristic;
            
        }
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:RESPONSE_CHARACTERISTIC_UUID]]) {
            NSLog(@"RESPONSE CHAR SET");
            
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];

            OJSDiscoveredPeripheral *p = (OJSDiscoveredPeripheral*)[_discoveredPeripherals objectForKey:peripheral.name];
            [p setResponseCharacteristic: (CBMutableCharacteristic *)characteristic];
            [_discoveredPeripherals setObject:p forKey:p.deviceIdentity];

            _responseCharacteristic = (CBMutableCharacteristic *)characteristic;
            
        }
        
        /*
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TEST_CHARACTERISTIC_UUID]]) {
            NSLog(@"TEST READ CHAR SET");
            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
            _testReadCharacteristic = (CBMutableCharacteristic *)characteristic;
        }
        */
        NSLog(@"loop");
    }
    
    [_connectedToParticipants lock];
    NSLog(@"wait for connected device is over");
    _waitForParticipants = FALSE;
    [_connectedToParticipants signal];
    [_connectedToParticipants unlock];

    
}

/*
 *  Receive the data here
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSLog(@"RECEIVE MCR");
    
    if (error) {
        NSLog(@"Error");
        return;
    }
    
    
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        NSLog(@"E O M");
        NSString *receivedText = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        
        if( [ [receivedText substringToIndex:3] isEqualToString:@"EOM" ])
        {
            receivedText = [receivedText substringFromIndex:3];
        }
        
        // TODO: react to this!!!
        NSLog(@"RECEIVED TEXT:  %@", receivedText);
        
        [self receiveText:receivedText];
        
        _data = [[NSMutableData alloc] init];
        [_data setLength:0];
        
        //[peripheral setNotifyValue:NO forCharacteristic:characteristic];
        //[_centralManager cancelPeripheralConnection:peripheral];
    }
    
    [_data appendData:characteristic.value];
}


- (void) peripheral: (CBPeripheral *) peripheral didUpdateNotificationStateForCharacteristic: (CBCharacteristic *) characteristic error: (NSError *) error {
    
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        return;
    }
    
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    } else {
        // Notification has stopped
        //[_centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//    _discoveredPeripheral = nil;

    NSLog(@"disconnected from peripheral: %@",peripheral.name);
    [_connectedPeripherals removeObjectForKey:peripheral.name];
    
    
    // start scanning again
    [_centralManager scanForPeripheralsWithServices:_participantServiceIDs options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    
}

- (void) cleanup
{
    
    for (CBPeripheral* discoveredPeripheral in _discoveredPeripherals) {

        @try {
            
        // See if we are subscribed to a characteristic on the peripheral
        if (discoveredPeripheral.services != nil) {
            for (CBService *service in discoveredPeripheral.services) {
                if (service.characteristics != nil) {
                    for (CBCharacteristic *characteristic in service.characteristics) {
                        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                            if (characteristic.isNotifying) {
                                [discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                                return;
                            }
                        }
                    }
                }
            }
        }
        
            
        //[_centralManager cancelPeripheralConnection:discoveredPeripheral];
        }
        @catch (NSException *exception) {
            NSLog(@"Error in cleanup %@", exception);
        }
    }
}









- (NSObject*) syncRemoteCall: (NSString *) deviceIdentity: (NSString *) capabilityName: (NSString *) methodName: (NSArray *) methodArgs
{
    NSLog(@"Invoking method: %@", methodName);
    
    NSLog(@"args %@", methodArgs);
    
    _waitingForMethodcallResponse = TRUE;
    
    NSString *actionId     = @"id3243434";
    NSString *methodCallId = @"id3243434_id3243434";
    
    NSArray *args = [NSArray arrayWithObjects:actionId,methodCallId,capabilityName,methodName,methodArgs, nil];
    
    
    NSMutableDictionary *methodCallObject = [NSMutableDictionary dictionaryWithObject:@"methodcall" forKey:@"name"];
    
    // do not require arguments
    if (methodArgs != nil) {
        [methodCallObject setObject:[NSArray arrayWithObject:args] forKey:@"args"];
    }
    
    NSString *methodcallString = [SocketIOJSONSerialization JSONStringFromObject:methodCallObject error:nil];
    
    
    NSLog(@"methodcallString: %@", methodcallString);
    
    NSString * jsonString = methodcallString;
    [self sendText:jsonString toDevice: deviceIdentity];
    
    
    // wait for response
    [_condition lock];
    while(_waitingForMethodcallResponse)
    {
        [_condition wait];
    }
    
    _waitingForMethodcallResponse = FALSE;
    [_condition unlock];
    
    
    NSLog(@"Got responseValue %@", _responseValue);
    
    return _responseValue;
};














-(void)sendText:(NSString*)textToSend toDevice: (NSString *) deviceIdentity
{
    
    //NSString *kisu = @"misukka";
    //NSData * data = [kisu dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"textToSend %@",textToSend);
    
    NSData * data = [textToSend dataUsingEncoding:NSUTF8StringEncoding];
    
    OJSDiscoveredPeripheral *p = [_discoveredPeripherals objectForKey:deviceIdentity];
    
    NSLog(@"got p %@", p.deviceIdentity);
    
    CBCharacteristic *responseCharacteristic = (CBCharacteristic*)[p responseCharacteristic];
    
    
    if(responseCharacteristic == NULL) {
        NSLog(@"response char NULLL");
    } else {
        NSLog(@"response char NOT null");
    }
    
    @try {
        
//        CBPeripheral *peripheral = p.peripheral;
        
        // calls didWriteValueForCharacteristic when client receives
        [p.peripheral writeValue:data forCharacteristic:responseCharacteristic type:CBCharacteristicWriteWithResponse];
        //[peripheral writeValue:data forCharacteristic:responseCharacteristic type:CBCharacteristicWriteWithoutResponse];
  

        
        NSLog(@"SENT MC");

    }
    @catch (NSException *exception) {
        NSLog(@"Error while sending text %@", exception);
    }
    
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSLog(@"DWV");
    
    if (error) {
        //        NSLog(@"Error writing characteristic value: %@", [error localizedDescription]);
        
        NSLog(@"Did write characteristic value : %@ with ID %@", characteristic.value, characteristic.UUID);
        NSLog(@"With error: %@", [error localizedDescription]);
        NSLog(@"Error writing characteristic value: %d", [error code]);
        
    }
}


-(void) receiveText:(NSString*)responseText
{
    
    NSLog(@"KUITAA");
    
    NSError *e;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [responseText dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &e];

    
    NSLog(@"name %@", JSON[@"name"]);
    if( [@"methodcallresponse" isEqualToString:JSON[@"name"]] )
    {
        NSLog(@"handling method call response");
        NSArray *args = JSON[@"args"];
        
        NSString * currentActionId = (NSString*)args[0][0];
        NSString * currentMethodId = (NSString*)args[0][1];

        
        // TODO: check that the response is from right method call!!
        
        @try {
            _responseValue = (NSObject *)args[0][2];
            NSString * valueType = (NSString*)args[0][3];
            NSLog(@"value is %@", _responseValue);
        }
        @catch (NSException *exception) {
            NSLog(@"Cannot parse responseVal: %@", exception);
        }
        
        [_condition lock];
        _responseJSONString = responseText;
        _waitingForMethodcallResponse = FALSE;
        [_condition signal];
        [_condition unlock];
        
    }
    
    

}









/*
 *  chunk send
 */


/*
- (void)dataSender {
    
    static BOOL sendingEOM = NO;
    
    // end of message?
    if (sendingEOM) {
        BOOL didSend = [_peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_transferCharacteristic onSubscribedCentrals:nil];
        
        if (didSend) {
            // It did, so mark it as sent
            sendingEOM = NO;
        }
        // didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're sending data
    // Is there any left to send?
    if (_sendDataIndex >= _dataToSend.length) {
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    BOOL didSend = YES;
    
    while (didSend) {
        // Work out how big it should be
        NSInteger amountToSend = _dataToSend.length - _sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:_dataToSend.bytes+_sendDataIndex length:amountToSend];
        
//        didSend = [_peripheralManager updateValue:chunk forCharacteristic:_responseCharacteristic onSubscribedCentrals:nil];
        [_discoveredPeripheral writeValue:chunk forCharacteristic:_responseCharacteristic type:CBCharacteristicWriteWithoutResponse];
      
        // If it didn't work, drop out and wait for the callback
        //if (!didSend) {
        //    return;
        //}
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        //        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        _sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (_sendDataIndex >= _dataToSend.length) {
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            BOOL eomSent = [_peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:_transferCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}



- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    [self dataSender];
}
*/




- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
    NSLog(@"peripheralManagerIsReadyToUpdateSubscribers");
}


- (CBPeripheral*) getDiscoveredPeripheralBy: (NSString *) deviceIdentity
{
    return [_discoveredPeripherals objectForKey: deviceIdentity];
}

- (CBPeripheral*) getConnectedPeripheralBy: (NSString *) deviceIdentity
{
    return [_connectedPeripherals objectForKey: deviceIdentity];
}



@end
