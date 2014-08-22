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


// temporary here
#import <AVFoundation/AVFoundation.h>
#import "OJSSettingsManager.h"

#import "OJSCentral.h"
#import "OJSPeripheral.h"


#import "TalkingCapability.h"

@interface OJSCapabilityController ()

    // add private methods and variables here
    @property (strong, atomic) OJSSettingsManager* settingsManager;

    @property (strong, nonatomic) OJSCentral* central;


    @property NSMutableDictionary * capabilities;

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
    // initialize capabilities here based on settings
    _capabilities = [[NSMutableDictionary alloc] init];
    for (NSString *capabilityName in [_settingsManager getDeviceCapabilities])
    {
        @try {
            id anObject = [[NSClassFromString(capabilityName) alloc] init];
            [_capabilities setObject:anObject forKey:capabilityName];
        }
        @catch (NSException *exception) {
            NSLog(@"Error while initializing: %@", capabilityName);
        }
    }
    return;
}



- (BOOL) initBLECentral: (NSArray *) participantInfo
{
    
    [_central initBTLECentral:nil: participantInfo];
    
    return true;
}





//- (NSObject *) executeCapability: (NSString *) capabilityName method: (NSString *) methodCallName with: (NSArray *) methodCallArguments
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




- (NSObject *) executeCapability: (NSString *) capabilityName method: (NSString *) methodCallName with: (NSArray *) methodCallArguments
{
    NSObject *object = [_capabilities objectForKey:capabilityName];
    return [self invokeMethod:capabilityName method:methodCallName with:methodCallArguments forNSObject:object];
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
        NSLog(@"NSObject -> returning: %@", returnValue);
        [invocation getReturnValue:&returnValue];
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