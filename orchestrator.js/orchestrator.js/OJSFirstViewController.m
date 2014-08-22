//
//  OJSFirstViewController.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 11.4.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import "OJSFirstViewController.h"
#import "OJSConnection.h"

#import "SocketIOPacket.h"
#import "OJSSettingsManager.h"


// Add private methods and variables here
@interface OJSFirstViewController ()
    
//    @property NSString *currentActionId;
//    @property NSString *currentMethodId;
    
//    @property (strong, nonatomic) OJSConnection *ojsConnection;
    @property OJSSettingsManager *settingsManager;


@end





@implementation OJSFirstViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    
    
    UIImageView *mainView = (UIImageView*)[self.view viewWithTag:1];
    _coordinationController = [[OJSCoordinationController alloc] init];
    [_coordinationController setMainUIView:mainView];

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



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
    NSLog(@"(re)connecting..");
    [_coordinationController initOJS];
}




-(IBAction)disconnectBtnTabbed
{
    NSLog(@"disconnecting..");
    [_coordinationController disconnectOJS];
}




@end
