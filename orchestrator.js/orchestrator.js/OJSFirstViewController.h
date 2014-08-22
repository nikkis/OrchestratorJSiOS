//
//  OJSFirstViewController.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 11.4.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

//#import "OJSDeviceCoordinator.h"

#import <AVFoundation/AVFoundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "OJSSettingsManager.h"
//#import "OJSHelpers.h"

//#import "OJSCapabilityController.h"

#import "OJSCoordinationController.h"

#import "SocketIO.h"
#import <UIKit/UIKit.h>

@interface OJSFirstViewController : UIViewController <SocketIODelegate> {
    
}


@property (strong) OJSCoordinationController * coordinationController;


// For background hack
@property (nonatomic, strong) AVPlayer *player;


-(IBAction)connectBtnTabbed;
-(IBAction)disconnectBtnTabbed;




@property (weak, nonatomic) IBOutlet UIImageView *blink;




@end




