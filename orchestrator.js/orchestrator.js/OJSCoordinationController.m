//
//  OJSCoordinationController.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 21.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OJSCoordinationController.h"


// Private propersties here
@interface OJSCoordinationController ()

@end



@implementation OJSCoordinationController



- (id) init
{
    self = [super init];
    if (self) {
        
        _ojsConnection = [[OJSConnection alloc] init];
        
        _settingsManager = [[OJSSettingsManager alloc] init];
        _ojsPeripheral = [[OJSPeripheral alloc] init];
        _actionController = [[OJSActionController alloc] init];

        // use setter for this
        _mainUIView = nil;
        
        // begin to advertise and act as peripheral
        [_ojsPeripheral initBLEPeripheral: _actionController];
        
//        _capabilityController = [[OJSCapabilityController alloc] init];
    }
    return self;
}



- (void) initOJS
{
    [_ojsConnection initOJS:_actionController];
}


- (void) disconnectOJS
{
    [_ojsConnection disconnectOJS];
}



@end