//
//  OJSCoordinationController.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 21.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//


// Top level controller for controlling all OJS coordination related stuff

#import "OJSConnection.h"
#import "OJSActionController.h"

#import "OJSPeripheral.h"

@interface OJSCoordinationController : NSObject

@property (strong) OJSActionController * actionController;
@property (strong) OJSConnection * ojsConnection;

@property (strong) OJSSettingsManager * settingsManager;

// BLE slave and iBeacon
@property (strong) OJSPeripheral * ojsPeripheral;


@property (strong) UIImageView * mainUIView;




- (void) initOJS;
- (void) disconnectOJS;


- (void) initScan;


@end