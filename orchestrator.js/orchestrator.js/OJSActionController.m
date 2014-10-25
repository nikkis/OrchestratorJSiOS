//
//  OJSActionController.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 15.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "OJSActionController.h"
#import "OJSCapabilityController.h"
#import "OJSSettingsManager.h"

#import "OJSHelpers.h"

#import "SocketIOJSONSerialization.h"

@interface OJSActionController ()

    @property (strong, atomic) OJSCapabilityController* capabilityController;
    @property (strong, atomic) OJSSettingsManager* settingsManager;


@end


@implementation OJSActionController

- (id) init
{
    self = [super init];
    if (self) {
        _settingsManager = [[OJSSettingsManager alloc] init];
        _capabilityController = [[OJSCapabilityController alloc] init];
    }
    return self;
}




- (void) initCapabilities
{
    [_capabilityController initCapabilities];
    return;
}



//
//  EXEC capability method
//
- (NSObject *) executeCapability: (NSString *) capabilityName method: (NSString *) methodCallName with: (NSArray *) methodCallArguments
{
    return [_capabilityController executeCapability:capabilityName method:methodCallName with:methodCallArguments by: _settingsManager.getDeviceIdentity];
}




//
//  EXEC action instance
//  Downloads it from OJS if the code has changed.
//
- (void) initializeActionInstance: (NSString *) actionID : (NSString *) actionName : (NSArray *) actionArgs : (NSArray *) participantInfo : (NSString *) actionVersionHash
{
    NSLog(@"invoking action instance");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        [self runActionInstanceThread:actionID :actionName :actionArgs :participantInfo : actionVersionHash];
    });
    
    
    
    
    
    return;
}






///////// PRIVATE METHODS



- (void) runActionInstanceThread: (NSString *) actionID : (NSString *) actionName : (NSArray *) actionArgs : (NSArray *) participantInfo : (NSString *) actionVersionHash
{
    //[_capabilityController bleCleanup];
   
    NSLog(@"Downloading action %@", actionName);
    NSString *filePath = [self downloadAction:actionName:actionVersionHash];
    
    NSLog(@"Connecting to devices");
    // Connect to devices
    if ([_capabilityController initBleCentral: participantInfo])
    {
        NSLog(@"Connected to all devices -> running action");
        NSLog(@"filepath %@", filePath);
        
        [self runAction: filePath : actionID : participantInfo : actionArgs];
    }
    else
    {
        NSLog(@"Could not connect to all devices");
    }
}



- (void) runAction: (NSString*) filePath : (NSString *) actionID : (NSArray *) participantInfo : (NSArray *) actionArgs
{
    
    
    JSContext *context = [[JSContext alloc] initWithVirtualMachine:[[JSVirtualMachine alloc] init]];

    context[@"bleCleanup"] = ^() {
        NSLog(@"💜 cleaning up Ble connections");
        //[_capabilityController bleCleanup];
    };
    
    
    context[@"consoleLog"] = ^(NSString *message) {
        NSLog(@"💜 Action console.log: %@", message);
    };

    
    context[@"invokeMethod"] = ^(NSString *deviceIdentity, NSString *capabilityName, NSString *methodName, NSArray *methodArgs) {
        
        NSLog(@"Invoking method: %@ for device: %@", methodName, deviceIdentity);
        NSLog(@"...with args %@", methodArgs);
        
        // TODO: add generator for this
        NSString *methodCallId = @"id3243434_id3243434";
        NSArray *args = [NSArray arrayWithObjects:actionID, methodCallId, capabilityName, methodName, methodArgs, nil];
        NSMutableDictionary *methodCallObject = [NSMutableDictionary dictionaryWithObject:@"methodcall" forKey:@"name"];
        
        // do not require arguments
        if (methodArgs != nil) {
            [methodCallObject setObject:[NSArray arrayWithObject:args] forKey:@"args"];
        }
        
        return [_capabilityController executeCapability:capabilityName method:methodName with:methodArgs by: deviceIdentity];
    };
    
    
    
    // Initialize DeviceStub
    NSString *deviceStubPath = [[NSBundle mainBundle] pathForResource:@"DeviceStub" ofType:@"js"];
    NSString *deviceStubCode = [NSString stringWithContentsOfFile:deviceStubPath encoding:NSUTF8StringEncoding error:nil];
    
    // Add helper functions to the context
    [context evaluateScript:deviceStubCode];
    
    
    // Load the action code from saved file
    NSMutableString *jscode = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSMutableString *ss = [NSMutableString stringWithString:@""];
    [ss appendString:jscode];
    
    // deviceModels (participantInfo)
    NSData *data = [NSJSONSerialization dataWithJSONObject:participantInfo options:0 error:nil];
    NSString *participantInfoJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [ss appendString:@"\nvar deviceModels = "];
    [ss appendString:participantInfoJSON];
    [ss appendString:@";\n"];

    // generate deviceStubs based on participantInfo
    [ss appendString:@"\nvar deviceStubs = createDevices( deviceModels );\n"];

    
    // parameters
    NSData *data2 = [NSJSONSerialization dataWithJSONObject:actionArgs options:0 error:nil];
    NSString *actionArgsJSON = [[NSString alloc] initWithData:data2 encoding:NSUTF8StringEncoding];
    [ss appendString:@"\nvar parameters = "];
    [ss appendString:actionArgsJSON];
    [ss appendString:@";\n"];
    
    // replace the device: strings with deviceStubs
    [ss appendString:@"\nreplaceIdsWithDevices( parameters );\n"];

    // execute the action code here
    [ss appendString:@"\nvar func = module.exports.body;\n"];
    [ss appendString:@"\nfunc.apply( this, parameters );\n"];



    
    NSLog(@"jsCode: %@", ss);
    
    
    [context evaluateScript:ss];
    NSLog(@"Action instance begin");
    
    
//    NSLog(@"Action instance ended -> cleanup!");
//    [_capabilityController bleCleanup];
    
}




- (NSString *) downloadAction: (NSString * ) actionName : (NSString *) actionVersionHash
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.js", documentsDirectory,actionVersionHash];
    
    // If file does not yet exist, download
    if( ![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSLog(@"action not yet exist");
        
        NSString* stringURL = [NSString stringWithFormat:@"http://%@:%@/api/1/action/%@",[_settingsManager getHostName], [_settingsManager getHostPort], actionName];
        NSURL  *url = [NSURL URLWithString:stringURL];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData )
        {
            [urlData writeToFile:filePath atomically:YES];
        }
        
    } else {
        NSLog(@"Action already exists");
    }
    return filePath;
}






@end


