//
//  OJSConnection.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 12.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OJSConnection.h"

#import "SocketIOPacket.h"
#import <AVFoundation/AVFoundation.h>

@interface OJSConnection ()

// add private methods and variables here

//    @property OJSCapabilityController *capabilityController;
    @property (strong, nonatomic) OJSSettingsManager *settingsManager;

    @property SocketIO *socketIO;

    @property NSString *currentActionId;
    @property NSString *currentMethodId;

    // backgound hack
    @property (nonatomic, strong) AVPlayer *player;



@end



@implementation OJSConnection




//- (void) initOJS: (UIImageView *) heartbeatIndicator
- (void) initOJS: (OJSActionController *) actionCtrl
{
    
    
    _settingsManager = [OJSSettingsManager settingsManager];

    _actionController = actionCtrl;
    
    _socketIO = [[SocketIO alloc] initWithDelegate:self];
    
    NSString *host = [_settingsManager getHostName];
    int port = [[_settingsManager getHostPort] intValue];
    
    [_socketIO connectToHost:host onPort:port];
    
    
    
    
    
    // background hack begins here
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&sessionError];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:@"silence" withExtension:@"mp3"]];
    [self setPlayer:[[AVPlayer alloc] initWithPlayerItem:item]];
    
    [[self player] setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    
    // with this method the app continuosly runs in background
    [[self player] play];
    
}

- (void) disconnectOJS
{
    [_socketIO disconnect];
    _socketIO = nil;
}



-(void)sendContextData: (NSDictionary*) contextData //for: (NSString *) key
{

    NSArray *arr = [NSArray arrayWithObjects: @"", [_settingsManager getDeviceIdentity], contextData, nil];
    NSLog(@"Sending context_data %@", arr);
    
    
    [_socketIO sendEvent:@"ojs_context_data" withData:arr];
    return;
}


/*
// UI stuff
-(void) _blinkImage
{
    //_bb = (UIImageView*)[self.view viewWithTag:1];
    [_bb setHidden:NO];
    
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //UIImageView * bb = (UIImageView*)[self.view viewWithTag:1];
        [_bb setHidden:YES];
    });
}
*/




# pragma mark -
# pragma mark socket.IO-objc delegate methods

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"socket.io connected.");
    
    NSArray *arr = [NSArray arrayWithObjects:[_settingsManager getDeviceIdentity], nil];
    [_socketIO sendEvent:@"login" withData:arr];
    NSLog(@"sent the login event");
}


- (void) socketIO:(SocketIO *)socket socketIODidReceiveHeartbeat:(SocketIOPacket *)packet
{
    NSLog(@"socket.io heartbeat received.");
    //[self _blinkImage];
    
}


- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    
    NSLog(@"type: %@", packet.name);
    
    
    
    NSLog(@"type: %@", packet.type);
    if( [@"methodcall" isEqualToString:packet.name] ) {
        
        @try {
            
            _currentActionId = (NSString*)packet.args[0][0];
            _currentMethodId = (NSString*)packet.args[0][1];
            
            NSString *capabilityName = (NSString*)packet.args[0][2];
            NSString *methodName = (NSString*)packet.args[0][3];
            
            NSArray *methodArguments = (NSArray*)packet.args[0][4];
            
            NSLog(@"executing method: %@", methodName );
            NSLog(@"with args: %@", methodArguments );
            
            
            NSObject * returnedValue = [_actionController executeCapability:capabilityName method:methodName with:methodArguments];
//            NSObject * returnedValue = [_capabilityController executeCapability:capabilityName method:methodName with:methodArguments];
                        
            NSArray *arr = [NSArray arrayWithObjects:_currentActionId, _currentMethodId, @"paluuarvo", @"STRING", nil];
            [_socketIO sendEvent:@"methodcallresponse" withData:arr];
            
            
            NSLog(@"methodcall_response sent");
            
        }
        @catch (NSException *exception) {
            NSLog(@"Error while handling method call %@", exception);
            
            NSArray *arr = [NSArray arrayWithObjects:_currentActionId, _currentMethodId, [_settingsManager getDeviceIdentity], (NSString*)exception.reason, nil];
            [_socketIO sendEvent:@"ojs_exception" withData:arr];
        }
        
        
        
        
    } else if( [@"ojs_action_instance" isEqualToString:packet.name] ) {
        NSLog(@"ojs_action_instance");
        
        @try {
            
            NSDictionary *actionArgs = (NSArray*)packet.args[0];

            NSString *actionName = [actionArgs objectForKey:@"actionName"];
            NSString *actionID = [actionArgs objectForKey:@"actionID"];
            NSArray *actionParams = [actionArgs objectForKey:@"actionParams"];
            NSArray *participantInfo = [actionArgs objectForKey:@"participantInfo"];
            NSString *actionVersionHash = [actionArgs objectForKey:@"actionVersionHash"];
            [_actionController initializeActionInstance: actionID : actionName : actionParams : participantInfo : actionVersionHash];
            
        }
        @catch (NSException *exception) {
            NSLog(@"Error whili initializing action instance: %@", exception);
        }
    
        
        
        
    // UNKNOWN COMMAND
    } else {
        NSLog(@"unknown command");
    }

}



- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    
    if ([error code] == SocketIOUnauthorized) {
        NSLog(@"not authorized");
    } else {
        NSLog(@"onError() %@", error);
    }
}


- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socket.io disconnected. did error occur? %@", error);
}

# pragma mark -






@end

