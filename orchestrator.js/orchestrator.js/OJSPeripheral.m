//
//  OJSiBeacon.m
//  orchestrator.js
//
//  Created by Niko on 7.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OJSPeripheral.h"
#import "OJSSettingsManager.h"


//#import "SocketIOJSONSerialization.h"

@interface OJSPeripheral ()

@property OJSSettingsManager *settingsManager;

@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

@property (strong, nonatomic) CBMutableCharacteristic *transferCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic *responseCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic *testReadCharacteristic;
@property (strong, nonatomic) NSData *dataToSend;




@property (nonatomic, readwrite) NSInteger sendDataIndex;


@property NSString *currentActionId;
@property NSString *currentMethodId;

@property OJSActionController * actionController;


@end


@implementation OJSPeripheral


- (BOOL) initBLEPeripheral: (OJSActionController *) actionCtrl
{
    NSLog(@"starting iBeacon advertisement");
    
    
    _actionController = actionCtrl;
    _settingsManager = [OJSSettingsManager settingsManager];
    
    NSString *btuuid = [_settingsManager getDeviceBTUUID];
    NSLog(@"starting ibeacon.. with btuuid: %@", btuuid);
    
    if (btuuid == nil) {
        NSLog(@"no btuuid.. cancel ibeacon..");
        return false;
    } else {
        // advertising
        NSLog(@"starting to advertise..");
        [self startAdvertising];
    }
    
    
    return true;
}




- (void) startAdvertising
{
    
    NSString *btuuid = [_settingsManager getDeviceBTUUID];
    NSLog(@"starting ibeacon.. with btuuid: %@", btuuid);
    
    
    _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    
    
//    NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey:[_settingsManager getDeviceIdentity], CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:[_settingsManager getDeviceBTUUID]]]};
    NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey:@"kakkapylly", CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:[_settingsManager getDeviceBTUUID]]]};
    
    [_peripheralManager startAdvertising:advertisingData];
    
}


- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    NSLog(@"peripheralManagerDidUpdateState");
    
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        
        NSString *btuuid = [_settingsManager getDeviceBTUUID];
        
        _transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
        
        //        _testReadCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TEST_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
        
        
        //      _responseCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:RESPONSE_CHARACTERISTIC_UUID] properties:              CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
        
        _responseCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:RESPONSE_CHARACTERISTIC_UUID] properties:        CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
        
        
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:btuuid]primary:YES];
        
        
        transferService.characteristics = @[_transferCharacteristic, _responseCharacteristic];//, _testReadCharacteristic];
        
        [_peripheralManager addService:transferService];
        
        // after placing these here this started WORKING!!
        
        NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey:[_settingsManager getDeviceIdentity], CBAdvertisementDataServiceUUIDsKey:@[[CBUUID UUIDWithString:[_settingsManager getDeviceBTUUID]]]};
        [_peripheralManager startAdvertising:advertisingData];
        
        
        NSLog(@"peripheralManagerDidUpdateState 1");
        
        
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"didSubscribeToCharacteristic with uuid %@", characteristic.UUID);
    NSLog(@"central id %@", central.identifier);
}






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
        
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
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
    
    NSLog(@"peripheralManagerIsReadyToUpdateSubscribers");
}


-(void)sendData:(NSString *)textToSend
{
    NSLog(@"SEND MCR");
    //    [self simpleSend:textToSend];
    [self chunkSend:textToSend];
}



-(void)simpleSend:(NSString*)textToSend
{
    NSLog(@"simpleSend begin");
    NSData * data = [textToSend dataUsingEncoding:NSUTF8StringEncoding];
    BOOL didSend = [self.peripheralManager updateValue:data forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
    didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
    NSLog(@"simpleSend end");
}




//
// Original send - more safe!
//
-(void)chunkSend:(NSString*)textToSend
{
    _dataToSend = [textToSend dataUsingEncoding:NSUTF8StringEncoding];
    _sendDataIndex = 0;
    
    [self dataSender];
}


- (void)setCurrentActionId:(NSString *)currentActionId
{
    @synchronized(self){
        _currentActionId = currentActionId;
    }
}

- (void)setCurrentMethodId:(NSString *)currentMethodId
{
    @synchronized(self){
        _currentMethodId = currentMethodId;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"didReceiveReadRequest");
}


// Processes write command received from a central.
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    NSLog(@"didReceiveWriteRequests");
    CBATTRequest*       request = [requests  objectAtIndex: 0];
    NSData* request_data = request.value;
    
    // tell coordinator that the method call was received..
    [peripheral respondToRequest:request    withResult:CBATTErrorSuccess];
    
    
    NSString *jsonString = [[NSString alloc] initWithData:request.value encoding:NSUTF8StringEncoding];
    NSLog(jsonString);
    
    if( [jsonString isEqualToString:@"kettu kettu"])
    {
        NSLog(@"KETTU");
        [self sendData:@"kui"];
        return;
    }
    
    
    
    // process the method call
    
    NSError *e;
    NSDictionary *JSON =
    [NSJSONSerialization JSONObjectWithData: [jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers error: &e];
    
    
    if( [@"methodcall" isEqualToString:JSON[@"name"]] )
    {
        NSLog(@"RECEIVED MC");
        
        NSLog(@"name %@", JSON[@"name"]);
        
        NSArray *args = JSON[@"args"];
        
        [self setCurrentActionId:(NSString*)args[0][0]];
        [self setCurrentMethodId:(NSString*)args[0][1]];
        
        NSString *capabilityName = (NSString*)args[0][2];
        NSString *methodName = (NSString*)args[0][3];
        
        NSArray *methodArguments = (NSArray*)args[0][4];
        
        
        NSLog(@"capability name: %@", capabilityName );
        NSLog(@"executing method: %@", methodName );
        NSLog(@"with args: %@", methodArguments );
        
        
        NSObject * responseVal = [_actionController executeCapability:capabilityName method:methodName with:methodArguments];
        
        [self sendMethodCallResponse:responseVal];
        return;
        
        
    }
    
}




-(void)sendMethodCallResponse:(NSObject*)value
{
    
    //valueType format: STRING, FLOAT, INT, DOUBLE, BOOL, JSON
    NSString *valueType = @"STRING";
    
    
    NSLog(@"response value %@", value);
    
    
    
    // for BOOLs use this!!
    //    NSArray *args = [NSArray arrayWithObjects:_currentActionId,_currentMethodId, [NSNumber numberWithBool:true], @"STRING", nil];
    NSArray *args;
    if( value == nil)
    {
        NSLog(@"nil value");
        args = [NSArray arrayWithObjects:_currentActionId,_currentMethodId, [NSNull null], @"STRING", nil];
    }
    //else if([value isKindOfClass:[NSString class]]){    }
    else
    {
        args = [NSArray arrayWithObjects:_currentActionId,_currentMethodId, value, @"STRING", nil];
    }
    
    
    NSMutableDictionary *methodCallResponseObject = [NSMutableDictionary dictionaryWithObject:@"methodcallresponse" forKey:@"name"];
    
    
    
    // do not require arguments
    if (args != nil) {
        [methodCallResponseObject setObject:[NSArray arrayWithObject:args] forKey:@"args"];
    }
    
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:methodCallResponseObject options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(jsonString);
    [self sendData:jsonString];
}






@end
