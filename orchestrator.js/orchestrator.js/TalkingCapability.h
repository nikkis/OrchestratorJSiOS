//
//  TalkingCapability.h
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 22.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>

@interface TalkingCapability : NSObject

- (void) say: (NSString *) line with: (NSString *) filter and: (NSString *) pitch;
- (void) shout: (NSString *) line with: (NSString *) filter and: (NSString *) pitch;

@property AVSpeechSynthesizer *synth;


@end



@implementation TalkingCapability




- (NSObject*) say: (NSString *) line : (NSString *) filter : (NSString *) pitch
{
    NSLog(@"Saying out loud: %@", line);
    
    
    
    _synth = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:line];
    
    
    //[synUtt setRate:speechSpeed];
    //[synUtt setVoice:[AVSpeechSynthesisVoice voiceWithLanguage:[AVSpeechSynthesisVoice currentLanguageCode]]];
    //[synthesizer speakUtterance:synUtt];
    
    [_synth speakUtterance:utterance];
    
    
    return nil;
}




- (void) shout: (NSString *) line with: (NSString *) filter and: (NSString *) pitch
{
    NSLog(@"Saying out loud: %@", line);
    
    
    
    return;
}




@end