//
//  OJSFirstViewController.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 11.4.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import "OJSDeviceCoordinator.h"

#import <AVFoundation/AVFoundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "SocketIO.h"
#import <UIKit/UIKit.h>

@interface OJSFirstViewController : UIViewController <SocketIODelegate> {
    SocketIO *socketIO;
    
    AVSpeechSynthesizer *synth;
    
    NSString *currentActionId;
    NSString *currentMethodId;
    
//    OJSDeviceCoordinator *deviceCoordinator;

}

@property (nonatomic, strong) OJSDeviceCoordinator *deviceCoordinator;

// For background hack
@property (nonatomic, strong) AVPlayer *player;


-(IBAction)connectBtnTabbed;
-(IBAction)disconnectBtnTabbed;

-(IBAction)initBTLEBtnTabbed;
-(IBAction)runActionBtnTabbed;


-(IBAction)rSendBtnTabbed;

-(IBAction)sinneJaTakasTabbed;

@property (weak, nonatomic) IBOutlet UIImageView *blink;


@end




