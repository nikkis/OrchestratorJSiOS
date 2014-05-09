//
//  OJSFirstViewController.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 11.4.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import "OJSFirstViewController.h"

#import "SocketIOPacket.h"

//#import "JsTalkingCapability.h"


@interface OJSFirstViewController ()

@end

@implementation OJSFirstViewController


- (void)initOJS
{
    
    // init talking capability
    synth = [[AVSpeechSynthesizer alloc] init];
    
    
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    
    //NSString *host = @"192.168.0.12";
    NSString *host = @"orchestratorjs.org";
    int port = 9000;
    
    [socketIO connectToHost:host onPort:port];
}

-(void)disconnectOJS
{
    [socketIO disconnect];
    socketIO = nil;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    
    //self.blink = (UIImageView *)[self.view viewWithTag:1];
    
    
    
    
    
    
    
    // background hack begins here
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&sessionError];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:@"silence" withExtension:@"mp3"]];
    [self setPlayer:[[AVPlayer alloc] initWithPlayerItem:item]];
    
    [[self player] setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    
    // with this method the app continuosly runs in background
    [[self player] play];
    
    // hack ends here
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







# pragma mark -
# pragma mark socket.IO-objc delegate methods

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceIdentity = [defaults objectForKey:@"deviceIdentity"];
    
    NSLog(@"socket.io connected.");
    
    NSArray *arr = [NSArray arrayWithObjects:deviceIdentity, nil];
    [socketIO sendEvent:@"login" withData:arr];
    NSLog(@"sent the login event");
}


- (void) socketIO:(SocketIO *)socket socketIODidReceiveHeartbeat:(SocketIOPacket *)packet
{
    NSLog(@"socket.io heartbeat received.");
    [self blinkImage];
    
}


- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    
    NSLog(@"type: %@", packet.name);
    
    NSLog(@"type: %@", packet.type);
    if( [@"methodcall" isEqualToString:packet.name] ) {
        
        currentActionId = (NSString*)packet.args[0][0];
        currentMethodId = (NSString*)packet.args[0][1];
        
        NSString *capabilityName = (NSString*)packet.args[0][2];
        NSString *methodName = (NSString*)packet.args[0][3];
        
        NSArray *methodArguments = (NSArray*)packet.args[0][4];
        
        NSLog(@"executing method: %@", methodName );
        NSLog(@"with args: %@", methodArguments );
        
        if( [@"TalkingCapability" isEqualToString:capabilityName] ) {

            if( [@"say" isEqualToString:methodName] ) {
                
                NSString * line = methodArguments[0];
                //NSString * filter = methodArguments[1];
                //NSString * pitch = methodArguments[2];
                
                AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:line];
                [synth speakUtterance:utterance];
                
            } else {
                NSLog(@"unknown method %@", methodName );
            }
            
        } else {
            NSLog(@"unknown capability %@", capabilityName);
        }
        
        NSArray *arr = [NSArray arrayWithObjects:currentActionId, currentMethodId, @"paluuarvo", @"STRING", nil];
        [socketIO sendEvent:@"methodcallresponse" withData:arr];
        NSLog(@"methodcall_response sent");
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


-(void)blinkImage
{
    UIImageView * bb = (UIImageView*)[self.view viewWithTag:1];
    [bb setHidden:NO];
    
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UIImageView * bb = (UIImageView*)[self.view viewWithTag:1];
        [bb setHidden:YES];
    });
}




-(IBAction)connectBtnTabbed
{
    

    [self blinkImage];
    
    
    NSLog(@"reconnecting..");
    [self initOJS];
}




-(IBAction)disconnectBtnTabbed
{

    
    NSLog(@"disconnecting..");
    [self disconnectOJS];
}


-(IBAction)initBTLEBtnTabbed
{
    self.deviceCoordinator = [[OJSDeviceCoordinator alloc] init];
    [self.deviceCoordinator initBTLECentral];
}


-(IBAction)runActionBtnTabbed
{
    NSLog(@"test btn");
    
    [self.deviceCoordinator runAction];
}



-(IBAction)rSendBtnTabbed
{
    [self.deviceCoordinator test];
}

-(IBAction)sinneJaTakasTabbed
{
    [self.deviceCoordinator sinneJaTakas];
}




@end
