//
//  OJSConnection.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 12.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OJSConnection.h"
#import "ToastView.h"


#import <AVFoundation/AVFoundation.h>


#import "orchestrator.js-Bridging-Header.h"
#import "orchestrator_js-Swift.h"


@interface OJSConnection ()

// add private methods and variables here

@property (strong, nonatomic) OJSSettingsManager *settingsManager;

@property SocketIOClient *socketIO;

@property NSString *currentActionId;
@property NSString *currentMethodId;


// backgound hack
@property (nonatomic, strong) AVPlayer *player;


@property UIView *mainView;

@end



@implementation OJSConnection




- (void) initOJS: (OJSActionController *) actionCtrl
{
    
    
    _settingsManager = [OJSSettingsManager settingsManager];
    
    _actionController = actionCtrl;
    
    
    //_socketIO = [[SocketIO alloc] initWithDelegate:self];
    
    NSString *host = [_settingsManager getHostName];
    NSInteger *port = [[_settingsManager getHostPort] intValue];
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"http://%@:%d", host, port];
    NSURL* url = [[NSURL alloc] initWithString: urlString];
    
    
    self.socketIO = [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @YES, @"forcePolling": @NO}];
    
    
    
    
    
    [self.socketIO on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket connected");
        [self socketIODidConnect:data withAck:ack];
    }];
    
    
    [self.socketIO on:@"methodcall" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"methodcall");
        [self methodcallWith:data];
    }];
    
    [self.socketIO on:@"ojs_action_instance" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"methodcall");
        [self methodcallWith:data];
    }];
    
    [self.socketIO on:@"heartbeat" callback:^(NSArray* data, SocketAckEmitter* ack) {
        [self _blinkImage];
    }];
    
    
    
    
    [self.socketIO on:@"disconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket disconnected");
        [self socketIODidDisconnectWithData:data andWithAck:ack];
    }];
    
    
    [self.socketIO on:@"error" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket error");
        [self socketIOErrorWithData:data andWithAck:ack];
    }];
    
    
    [self.socketIO connect];
    
    
    
    
    
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
    
    NSLog(@"FOOO1");
    
    //NSArray *arr = [NSArray arrayWithObjects: @"", [_settingsManager getDeviceIdentity], contextData, nil];
    
    NSArray *arr = [NSArray arrayWithObjects: @"", [_settingsManager getDeviceIdentity], contextData, nil];
    
    NSLog(@"Sending context_data %@", arr);
    
    
    [self.socketIO emit:@"ojs_context_data" with:arr];
    return;
}



// UI stuff
-(void) _blinkImage
{
    UIImageView* _bb = (UIImageView*)[_mainView viewWithTag:1];
    [_bb setHidden:NO];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //UIImageView * bb = (UIImageView*)[self.view viewWithTag:1];
        [_bb setHidden:YES];
    });
}




# pragma mark -
# pragma mark socket.IO-objc delegate methods


- (void) socketIODidConnect: (NSArray*) data withAck: (SocketAckEmitter*) ack
{
    NSLog(@"socket.io connected.");
    _IS_CONNECTED = TRUE;
    NSArray *arr = [NSArray arrayWithObjects:[_settingsManager getDeviceIdentity], nil];
    
    
    
    [_socketIO emit:@"login" with:arr];
    
    
    NSLog(@"sent the login event");
    [self _blinkImage];
}




- (void) methodcallWith: (NSArray*) arguments
{
    
    
    _IS_CONNECTED = TRUE;
    
    
    @try {
        
        _currentActionId = arguments[0][0];
        _currentMethodId = arguments[0][1];
        
        NSString *capabilityName = arguments[0][2];
        NSString *methodName = arguments[0][3];
        
        NSArray *methodArguments = arguments[0][4];
        
        NSLog(@"executing method: %@", methodName );
        NSLog(@"with args: %@", methodArguments );
        
        
        NSObject * returnedValue = [_actionController executeCapability:capabilityName method:methodName with:methodArguments];
        
        
        NSLog(@"response val: %@", returnedValue);
        NSArray *arr = [NSArray arrayWithObjects:_currentActionId, _currentMethodId, returnedValue, @"STRING", nil];
        
        //[_socketIO sendEvent:@"methodcallresponse" withData:arr];
        [_socketIO emit:@"methodcallresponse" with:arr];
        
        NSLog(@"methodcall_response sent");
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"Error while handling method call %@", exception);
        
        NSArray *arr = [NSArray arrayWithObjects:_currentActionId, _currentMethodId, [_settingsManager getDeviceIdentity], (NSString*)exception.reason, nil];
        [_socketIO emit:@"ojs_exception" with:arr];
        
    }
}

- (void) actionInstanceWith: (NSArray*) arguments
{
    
    NSLog(@"ojs_action_instance");
    
    @try {
        
        NSDictionary *actionArgs = arguments[0];
        
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
    
}




- (void) socketIOErrorWithData:(NSArray*) data andWithAck: (SocketAckEmitter*) ack
{
    
//    if ([error code] == SocketIOUnauthorized) {
//        NSLog(@"not authorized");
//        [ToastView showToastInParentView:_mainView withText:@"Unauthorized" withDuaration:TOAST_DURATION_LONG];
//    } else {
        NSLog(@"onError() %@", data[0]);
        [ToastView showToastInParentView:_mainView withText:@"Issues while connecting!" withDuaration:TOAST_DURATION_LONG];
//    }
    
}



- (void) socketIODidDisconnectWithData:(NSArray*) data andWithAck: (SocketAckEmitter*) ack
{
    [ToastView showToastInParentView:_mainView withText:@"Disconnected!" withDuaration:TOAST_DURATION_LONG];
    NSLog(@"socket.io disconnected. did error occur? %@", data[0]);
    _IS_CONNECTED = FALSE;
}

# pragma mark -


- (void) setView:(UIView*)view
{
    _mainView = view;
}



@end

