//
//  OJSDeviceCoordinator.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 22.4.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import "OJSDeviceCoordinator.h"

#import "JsTalkingCapability.h"

#import "SocketIOJSONSerialization.h"



@implementation OJSDeviceCoordinator


-(void)initBTLECentral
{
    [self initCentral];
}




-(void) runAction
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [self runActionThread];
        
    });
}

-(void) runActionThread
{

    
    NSString *actionName = @"myscript2";
//    NSString *actionName = @"TestLag";
    
    JSContext *context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];
    
    context[@"consoleLog"] = ^(NSString *message) {
        NSLog(@"JavaScrip console: %@", message);
    };
    
    
    
    context[@"invokeMethod"] = ^(NSString *capabilityName, NSString *methodName, NSArray *methodArgs) {
        NSLog(@"Invoking method: %@", methodName);
        
        NSLog(@"args %@", methodArgs);
        
        self.waitingForMethodcallResponse = TRUE;
        
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
        [self sendText:jsonString];
        
        
        // wait for response
        [condition lock];
        while(self.waitingForMethodcallResponse)
        {
            [condition wait];
        }
        
        self.waitingForMethodcallResponse = FALSE;
        [condition unlock];
        
        
        NSLog(@"Got responseValue %@", self.responseValue);
        
        return self.responseValue;
    };
    
    
    // Initialize DeviceStub
    NSString *deviceStubPath = [[NSBundle mainBundle] pathForResource:@"DeviceStub" ofType:@"js"];
    NSString *deviceStubCode = [NSString stringWithContentsOfFile:deviceStubPath encoding:NSUTF8StringEncoding error:nil];
    [context evaluateScript:deviceStubCode];

    
    
    // Run the Action code
    NSString *path = [[NSBundle mainBundle] pathForResource:actionName ofType:@"js"];
    NSString *jscode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    [context evaluateScript:jscode];
    
    NSLog(@"bar");
    
}


/*
 *
 *      Bluetooth LE Begins here
 *
 */



- (void)initCentral
{
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    _data = [[NSMutableData alloc] init];
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // You should test all scenarios
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        // Scan for devices
        [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        NSLog(@"Scanning started");
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {

    NSLog(@"Discovered %@ at %@, with identifier %@", peripheral.name, RSSI, peripheral.identifier);
    
    if (_discoveredPeripheral != peripheral) {
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        _discoveredPeripheral = peripheral;
        
        // And connect
        NSLog(@"Connecting to peripheral %@", peripheral);
        [_centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect");
    [self cleanup];
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected");
    
    [_centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    [_data setLength:0];
    
    peripheral.delegate = self;
    
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        [self cleanup];
        return;
    }

    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:RESPONSE_CHARACTERISTIC_UUID]] forService:service];
        
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TEST_CHARACTERISTIC_UUID]] forService:service];
    }
    
    
/*
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:RESPONSE_CHARACTERISTIC_UUID]] forService:service];
    }
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TEST_CHARACTERISTIC_UUID]] forService:service];
    }
*/
    
    // Discover other characteristics
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        [self cleanup];
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            NSLog(@"TRANSFER CHAR SET");
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            self.transferCharacteristic = (CBMutableCharacteristic *)characteristic;
            
        }
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:RESPONSE_CHARACTERISTIC_UUID]]) {
            NSLog(@"RESPONSE CHAR SET");
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            self.responseCharacteristic = (CBMutableCharacteristic *)characteristic;
        }
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TEST_CHARACTERISTIC_UUID]]) {
            NSLog(@"TEST READ CHAR SET");
            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
            self.testReadCharacteristic = (CBMutableCharacteristic *)characteristic;
        }
        NSLog(@"loop");
    }
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
        NSString *receivedText = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        
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


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
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
    _discoveredPeripheral = nil;
    
    [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}

- (void)cleanup {
    
    // See if we are subscribed to a characteristic on the peripheral
    if (_discoveredPeripheral.services != nil) {
        for (CBService *service in _discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            [_discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            return;
                        }
                    }
                }
            }
        }
    }
    
    [_centralManager cancelPeripheralConnection:_discoveredPeripheral];
}



-(IBAction)scanBtnTabbed
{
    [self initCentral];
}


-(void)sinneJaTakas
{
    NSLog(@"KETTU");
//    NSString *st = @"kettu kettu kettu kettu kettu kettu kettu kettu kettu kettu kettu kettu kettu kettu kettu";
    NSString *st = @"kettu kettu";
    [self sendText:st];
}


-(void)test
{
    NSLog(@"test btn");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
        [self testThreadAction];
    
    });
}



-(void) testThreadAction
{
    NSString * jsonString = @"TEST";
    
    NSArray *args = [[NSArray alloc] init];
    
    [self syncRemoteCall:@"TestCapability" :@"initMeasurement" :args];
    
    for (int i=0; i<16; i+=1) {
        //[self sendText:jsonString];
        [self syncRemoteCall:@"TestCapability" :@"dummyMethod" :args];
    }
}







-(void)syncRemoteCall: (NSString *)capabilityName: (NSString *) methodName: (NSArray *)methodArgs
{
    NSLog(@"Invoking method: %@", methodName);
    
    NSLog(@"args %@", methodArgs);
    
    self.waitingForMethodcallResponse = TRUE;
    
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
    [self sendText:jsonString];
    
    
    // wait for response
    [condition lock];
    while(self.waitingForMethodcallResponse)
    {
        [condition wait];
    }
    
    self.waitingForMethodcallResponse = FALSE;
    [condition unlock];
    
    
    NSLog(@"Got responseValue %@", self.responseValue);
    
};












-(IBAction)rSendBtnPressed
{
    NSLog(@"r send!!");
    
    NSString * jsonString = @"asdfasfasd asdfasdf asdf asdf sadf asdf asdf sadf asdf dasf dsaf  sadfadsfasdf sadf sadf asdf asdf asfd";
    [self sendText:jsonString];
}



-(void)sendText:(NSString*)textToSend
{
    NSData * data = [textToSend dataUsingEncoding:NSUTF8StringEncoding];
    
    if(self.responseCharacteristic == NULL) {
        NSLog(@"response char NULLL");
    } else {
        NSLog(@"response char NOT null");
    }
    
    
    // calls didWriteValueForCharacteristic when client receives
    [self.discoveredPeripheral writeValue:data forCharacteristic:self.responseCharacteristic type:CBCharacteristicWriteWithResponse];
//    [self.discoveredPeripheral writeValue:data forCharacteristic:self.responseCharacteristic type:CBCharacteristicWriteWithoutResponse];
    
    NSLog(@"SENT MC");

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
        
        self.responseValue = (NSObject *)args[0][2];
        NSString * valueType = (NSString*)args[0][3];
        
        NSLog(@"value is %@", self.responseValue);
        
        
        self.responseJSONString = responseText;
        self.waitingForMethodcallResponse = FALSE;
        
        [condition signal];
        [condition unlock];
        
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
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        if (didSend) {
            // It did, so mark it as sent
            sendingEOM = NO;
        }
        // didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're sending data
    // Is there any left to send?
    if (self.sendDataIndex >= self.dataToSend.length) {
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    BOOL didSend = YES;
    
    while (didSend) {
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
//        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.responseCharacteristic onSubscribedCentrals:nil];
        [self.discoveredPeripheral writeValue:chunk forCharacteristic:self.responseCharacteristic type:CBCharacteristicWriteWithoutResponse];
      
        // If it didn't work, drop out and wait for the callback
        //if (!didSend) {
        //    return;
        //}
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        //        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
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




@end
