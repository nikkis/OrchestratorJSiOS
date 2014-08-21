//
//  OJSConnection.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 12.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import "OJSActionController.h"
#import "OJSSettingsManager.h"
#import "SocketIO.h"

@interface OJSConnection : NSObject <SocketIODelegate>
{
}

- (void) initOJS: (OJSActionController*) actionCtrl;
- (void) disconnectOJS;

- (void) sendContextData: (NSDictionary*) contextData;



@property (strong, atomic) OJSActionController *actionController;

@end