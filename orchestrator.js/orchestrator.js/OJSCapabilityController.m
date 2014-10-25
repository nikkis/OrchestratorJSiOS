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




@interface OJSCapabilityController ()

    // add private methods and variables here
    @property (strong, atomic) OJSSettingsManager* settingsManager;

    @property (strong, nonatomic) OJSCentral* central;


    @property (strong, nonatomic) NSMutableDictionary * capabilities;

    // key format: CapabilityName::methodName
    @property NSMutableDictionary * capabilityMethodSelectors;

    @property BOOL waitingForMethodFinished;
    @property NSCondition *waitUntilMethodFinished;


@property (strong, atomic) NSObject *returnObject;


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
    _capabilityMethodSelectors = [[NSMutableDictionary alloc] init];
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
            
            if(anObject) {
                NSLog(@"generating seletor for capability: %@", capabilityName);
                int i=0;
                unsigned int mc = 0;
                Method * mlist = class_copyMethodList(object_getClass(anObject), &mc);
                for(i=0;i<mc;i++) {
                    NSString *selectorName = [NSString stringWithFormat:@"%s", sel_getName(method_getName(mlist[i]))];
                    NSArray *selectorNameParts = [selectorName componentsSeparatedByString: @":"];
                    if(selectorNameParts != nil && [selectorNameParts count] != 0) {
                        [_capabilityMethodSelectors setObject:selectorName forKey:[NSString stringWithFormat:@"%@::%@",capabilityName,selectorNameParts[0]]];
                        [_capabilities setObject:anObject forKey:capabilityName];
                    }
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Error: %@ while initializing capability: %@", exception, capabilityName);
        }
    }
    return;
}



- (BOOL) initBleCentral: (NSArray *) participantInfo
{
    [_central initBTLECentral:nil: participantInfo];
    return true;
}


- (void) bleCleanup
{
    [_central cleanup];
    return;
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

    NSLog(@"bar - 0");

//    [self setReturnObject:nil];
    NSLog(@"bar - 1");

    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
NSLog(@"bar - 00");
        NSObject *rO = [[NSObject alloc] init];
        //@try {
        [_waitUntilMethodFinished lock];
            NSObject *object = [[TestCapability alloc] init];//[_capabilities objectForKey:capabilityName];
NSLog(@"bar - 01");
            rO = [self invokeMethod:capabilityName method:methodCallName with:methodCallArguments forNSObject:object];
            //object = nil;
NSLog(@"bar - 02");

        //} @catch (NSException *exception) {
          //  NSLog(@"Error while executing method: %@", exception);
            // TODO: sent error to OJS (and notify all the devices)
            //            [self setReturnObject:nil];
        //} @finally {

            NSLog(@"bar - 03");
            
            //[_waitUntilMethodFinished lock];
            
            NSLog(@"rO: %@",rO);
            
            // toimii
            //rO = @"muimoi";
            //[self setReturnObject:rO];
            
            
            // This might be the solution!!!!
            NSMutableString *mm = [[NSMutableString alloc] initWithFormat:@"jaa%@", (NSString*)rO];
            
            // ei toimi
//            [self setReturnObject:mm];
                    [self setReturnObject:@"jaa"];
NSLog(@"bar - 04");
            
            _waitingForMethodFinished = FALSE;
            [_waitUntilMethodFinished signal];
            [_waitUntilMethodFinished unlock];
        //}

        
    });
    NSLog(@"bar - 2");
    
    NSObject *retObj = [[NSObject alloc] init];
    NSLog(@"waiting for method call to finish - BEGINS");
    [_waitUntilMethodFinished lock];
    while(_waitingForMethodFinished)
    {
        [_waitUntilMethodFinished wait];
    }
    retObj = [_returnObject copy];
    NSLog(@"_returnObject: %@",_returnObject);
    [_waitUntilMethodFinished unlock];

    retObj = [_returnObject copy];
    
    NSLog(@"waiting for method call to finish - IS OVER");
    return retObj;
}






- (NSObject *) invokeMethod: (NSString *) className method: (NSString *) methodName with: (NSArray *) methodArguments forNSObject: (NSObject *) object
{
    

    NSString *selectorString = [_capabilityMethodSelectors objectForKey:[NSString stringWithFormat:@"%@::%@",className,methodName]];
    
    NSLog(@"selectorString: %@", selectorString);
    
    SEL selector = NSSelectorFromString(selectorString);
    Method method = class_getInstanceMethod([object class], selector);
    if(method == nil) {
        NSLog(@"method nil");
        [NSException raise:@"WrongNumberOfArguments" format:@"Wrong number of arguments OR wrong argument naming (selector string argument names) for method %@::%@ (code01)", className, methodName];
    }
    
    int argumentCount = method_getNumberOfArguments(method);
    NSLog(@"argumentCount %i",argumentCount);
    NSLog(@"method Args count %lu",(unsigned long)[methodArguments count]);
    if(argumentCount > [methodArguments count] + 2) {
        NSLog(@"argument count does not match");
        [NSException raise:@"WrongNumberOfArguments" format:@"Wrong number of arguments for method %@::%@ (code02)", className, methodName];
    }
    
    NSMethodSignature *signature = [[object class] instanceMethodSignatureForSelector:selector];
    if(signature == nil) {
        NSLog(@"signature nil");
        [NSException raise:@"NoSuchMethod" format:@"Method not found (%@::%@). Check capability definition and the number of method parameters.(code03)", className, methodName];
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
    if(*ret == '@')
    {
        
        ///// TESTING BEGINS
        
        
        // MAYBE WORKS
        CFTypeRef result;
        [invocation getReturnValue:&result];
        if (result)
            CFRetain(result);
        NSObject *rrrr = (__bridge_transfer NSObject *)result;
        return rrrr;
        
        
        ///// TESTING ENDS

        
        
        // DOES NOT WORKS
        //NSObject *returnValue = [[NSObject alloc] init];
        //[invocation getReturnValue:&returnValue];
        //NSLog(@"NSObject -> returning: %@", returnValue);
        // EXC_BAD_ACCESS
        //return [returnValue copy];
        
        
        // WORKS
        //return nil;
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



/*
-(void)setReturnObject:(NSObject *)returnObject
{
    @synchronized(self) {
        _returnObject = returnObject;
    }
}




- (NSObject *)returnObject
{
    NSObject *ret = nil;
    
    @synchronized (self)
    {
        ret = [[_returnObject retain] autorelease];
    }
    
    return ret;
}
*/

@end