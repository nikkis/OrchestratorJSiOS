//
//  OJSCapabilityController.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 13.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface OJSCapabilityController : NSObject
{

}


- (void) connectToBLEDevices: (NSArray *) deviceIdentities;



- (void) initCapabilities;

- (BOOL) initBLECentral: (NSArray *) participantInfo;

- (NSObject *) executeCapability: (NSString *) capabilityName method: (NSString *) methodCallName with: (NSArray *) methodCallArguments by: (NSString*) deviceIdentity;




@end