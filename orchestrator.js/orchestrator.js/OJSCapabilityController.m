//
//  OJSCapabilityController.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 13.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "OJSCapabilityController.h"

#import "orchestrator_js-Swift.h"

#import "OJSSettingsManager.h"

#import "OJSCentral.h"
#import "OJSPeripheral.h"

//#import "CAPABILITY_IMPORTS.h"

#import "orchestrator.js-Bridging-Header.h"
//#import "orchestrator_js-Swift.h"



@interface OJSCapabilityController ()

    // add private methods and variables here
    @property (strong, atomic) OJSSettingsManager* settingsManager;

    @property (strong, nonatomic) OJSCentral* central;


    @property NSMutableDictionary * capabilities;

    @property BOOL waitingForMethodFinished;
    @property NSCondition *waitUntilMethodFinished;
    @property NSObject *returnObject;

@end


@implementation OJSCapabilityController


- (id) init
{
    self = [super init];
    if (self) {
        _settingsManager = [[OJSSettingsManager alloc] init];
        _central = [[OJSCentral alloc] init];
        _capabilities = [[NSMutableDictionary alloc] init];

    }
    return self;
}


- (void) initCapabilities
{
    
    //id ooo = [[TestCapability alloc] init];

    //id oo = [[TalkingCapability alloc] init];

    
    //id oo = [[ alloc] init];
    //[oo test];
    
    
    
    // initialize capabilities here based on settings
    _capabilities = [[NSMutableDictionary alloc] init];
    for (NSString *capabilityName in [_settingsManager getDeviceCapabilities])
    {
        @try {
            
            
            NSLog(@"importing capability %@", capabilityName);
            id anObject = [[NSClassFromString(capabilityName) alloc] init];
            if(anObject == nil) {
                NSString* swifClassName = [NSString stringWithFormat:@"%@%@",@"orchestrator_js.", capabilityName];
                NSLog(@"trying to import swift class: %@", swifClassName);
                anObject = [[NSClassFromString(swifClassName) alloc] init];
            }
            
            [_capabilities setObject:anObject forKey:capabilityName];
        }
        @catch (NSException *exception) {
            NSLog(@"Error: %@ while initializing capability: %@", exception, capabilityName);
        }
    }
    
    
    /*
    NSString* swifClassName = @"orchestrator_js.TalkingCapability";
    NSLog(@"trying to import swift class: %@", swifClassName);
    id anObject2 = [[NSClassFromString(swifClassName) alloc] init];
    if(anObject2) {
        NSLog(@"NULLLLI");
    } else {
        NSLog(@"jeee");
    }*/
    return;
}



- (BOOL) initBLECentral: (NSArray *) participantInfo
{
    
    [_central initBTLECentral:nil: participantInfo];
    
    return true;
}





- (NSObject *) executeCapability: (NSString *) capabilityName method: (NSString *) methodCallName with: (NSArray *) methodCallArguments by: (NSString*) deviceIdentity
{
    
    
    // local method call
    if ([_settingsManager.getDeviceIdentity isEqualToString:deviceIdentity])
    {
        NSLog(@"Jep mina ite!");
        return [self executeCapability:capabilityName method:methodCallName with:methodCallArguments];
    }
    
    // Other than me:
    else
    {
        //BLE method call
        NSLog(@"kuka muu muka? -> BLE");
        return [_central syncRemoteCall:deviceIdentity :capabilityName :methodCallName :methodCallArguments];
        
        // command through OJS
    }
    
    

    
    
    
    
    return nil;
}



// Exec method call on THIS device
- (NSObject *) executeCapability: (NSString *) capabilityName method: (NSString *) methodCallName with: (NSArray *) methodCallArguments
{
    _waitingForMethodFinished = TRUE;
    _waitUntilMethodFinished = [[NSCondition alloc] init];
    
    _returnObject = nil;
    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{

        @try {
            NSObject *object = [_capabilities objectForKey:capabilityName];
            _returnObject = [self invokeMethod:capabilityName method:methodCallName with:methodCallArguments forNSObject:object];

        }
        @catch (NSException *exception) {
            NSLog(@"Error while executing method: %@", exception);
            // TODO: sent error to OJS (and notify all the devices)
            _returnObject = nil;
        }
        @finally {
            [_waitUntilMethodFinished lock];
            _waitingForMethodFinished = FALSE;
            [_waitUntilMethodFinished signal];
            [_waitUntilMethodFinished unlock];
        }

        
    });
    
    NSLog(@"waiting for method call to finish - BEGINS");
    [_waitUntilMethodFinished lock];
    while(_waitingForMethodFinished)
    {
        [_waitUntilMethodFinished wait];
    }
    [_waitUntilMethodFinished unlock];

    NSLog(@"waiting for method call to finish - IS OVER");
    return _returnObject;
}






- (NSObject *) invokeMethod: (NSString *) className method: (NSString *) methodName with: (NSArray *) methodArguments forNSObject: (NSObject *) object
{

    NSMutableString *selectorString = [[NSMutableString alloc]initWithString:methodName];
    for (int i = 0; i < [methodArguments count]; i++) {
        [selectorString appendString:@":"];
    }
    
    SEL selector = NSSelectorFromString(selectorString);

    
    Method method = class_getInstanceMethod([object class], selector);
    int argumentCount = method_getNumberOfArguments(method);
    
    if(argumentCount > [methodArguments count] + 2) {
        [NSException raise:@"WrongNumberOfArguments" format:@"Wrong number of arguments for method %@::%@", className, methodName];
    }
    
    
    NSMethodSignature *signature = [[object class] instanceMethodSignatureForSelector:selector];
    if(signature == nil) {
        NSLog(@"signature nil");
        [NSException raise:@"NoSuchMethod" format:@"Method not found (%@::%@). Check capability definition and the number of method parameters.", className, methodName];
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:object];
    [invocation setSelector:selector];
    
    
    for(int i=0; i<[methodArguments count]; i++)
    {
        id arg = [methodArguments objectAtIndex:i];
        [invocation setArgument:&arg atIndex:i+2]; // The first two arguments are the hidden arguments self and _cmd
    }
    

    [invocation invoke]; // Invoke the selector

    char ret[ 256 ];
    method_getReturnType( method, ret, 256 );
    NSString *s = [[NSString alloc] initWithBytes:ret + 2 length:3 encoding:NSUTF8StringEncoding];
    NSObject *returnValue;
    if(*ret == '@')
    {
        NSObject *returnValue;
        [invocation getReturnValue:&returnValue];
        NSLog(@"NSObject -> returning: %@", returnValue);
        return returnValue;
    }
    else if ( *ret == 'v')
    {
        NSLog(@"voidi -> returning nil");
        return nil;
    }
    else
    {
        NSLog(@"some other type -> returning nil");
        return nil;
    }
}








@end