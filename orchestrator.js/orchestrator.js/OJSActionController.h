//
//  OJSActionController.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 15.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//
@interface OJSActionController : NSObject


@property BOOL executingAction;


- (void) initCapabilities;


- (void) initializeActionInstance: (NSString *) actionID : (NSString *) actionName : (NSArray *) actionArgs : (NSArray *) participantInfo : (NSString *) actionVersionHash;

- (NSObject *) executeCapability: (NSString *) capabilityName method: (NSString *) methodCallName with: (NSArray *) methodCallArguments;




@end