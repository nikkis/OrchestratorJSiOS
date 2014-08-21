//
//  OJSCapabilityController.m
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 13.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OJSCapabilityController.h"


// temporary here
#import <AVFoundation/AVFoundation.h>
#import "OJSSettingsManager.h"

#import "OJSCentral.h"
#import "OJSPeripheral.h"

@interface OJSCapabilityController ()

// add private methods and variables here
@property (strong, atomic) OJSSettingsManager* settingsManager;

@property (strong, nonatomic) OJSCentral* central;
//@property (strong, nonatomic) OJSPeripheral* peripheral;



@end


@implementation OJSCapabilityController


- (id) init
{
    self = [super init];
    if (self) {
        _settingsManager = [[OJSSettingsManager alloc] init];
        
        _central = [[OJSCentral alloc] init];
        
//        _peripheral = [[OJSPeripheral alloc] init];
    }
    return self;
}


- (BOOL) initBLECentral: (NSArray *) participantInfo
{
    
    [_central initBTLECentral:nil: participantInfo];
    
    return true;
}

/*
- (BOOL) initBLEPeripheral
{
    return [_peripheral initBLEPeripheral];
}*/



//- (NSObject *) executeCapability: (NSString *) capabilityName method: (NSString *) methodCallName with: (NSArray *) methodCallArguments
- (NSObject *) executeCapability: (NSString *) capabilityName method: (NSString *) methodCallName with: (NSArray *) methodCallArguments by: (NSString*) deviceIdentity
{
    
    
    // local method call
    if ([_settingsManager.getDeviceIdentity isEqualToString:deviceIdentity])
    {
        NSLog(@"Jep mina ite!");
        return [self executeCapability:capabilityName method:methodCallName with:methodCallArguments];
    }
    
    // Other than me:
    else
    {
        //BLE method call
        NSLog(@"kuka muu muka? -> BLE");
        return [_central syncRemoteCall:deviceIdentity :capabilityName :methodCallName :methodCallArguments];
        
        // command through OJS
    }
    
    

    
    
    
    
    return nil;
}




- (NSObject *) executeCapability: (NSString *) capabilityName method: (NSString *) methodCallName with: (NSArray *) methodCallArguments
{
    
    
    if( [@"TalkingCapability" isEqualToString:capabilityName] ) {
        
        if( [@"say" isEqualToString:methodCallName] ) {
            NSLog(@"foo1 ");
            NSString * line = methodCallArguments[0];
            //NSString * filter = methodArguments[1];
            //NSString * pitch = methodArguments[2];
            NSLog(@"foo2 ");
            
            NSLog(@"line %@", line);
            
            // IMPORTANT! must check for nil values as NSInvalidArgumentException cannot be catched!
            if (line == nil || line == (id)[NSNull null])
            {
                [NSException raise:@"InvalidParameter" format:@"Invalid value (%s) for parameter: line (method TalkingCapaility::say)", line];
            }
            
            
            AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
            AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:line];
            
            
            //[synUtt setRate:speechSpeed];
            //[synUtt setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:[AVSpeechSynthesisVoice currentLanguageCode]]];
            //[synthesizer speakUtterance:synUtt];
            
            [synth speakUtterance:utterance];
            
            
        } else {
            NSLog(@"unknown method %@", methodCallName );
        }
        
    } else {
        NSLog(@"unknown capability %@", capabilityName);
    }
    
    
    return nil;
}




/*
- (void) connectToBLEDevices: (NSArray *) deviceIdentities
{
    
    NSLog(@"connecting to BLE devices with deviceIdentities: %@", deviceIdentities);
    
    return;
}
*/



@end