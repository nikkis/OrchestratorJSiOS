//
//  TalkingCapability.swift
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 28.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

import Foundation
import AVFoundation


@objc
class TalkingCapability : NSObject, AVSpeechSynthesizerDelegate
{
    let speechSynthesizer = AVSpeechSynthesizer()
    
    
    override init() {
        super.init()
        speechSynthesizer.delegate = self
    }
    
    
    func say(_ line: String, filter: String, pitch: String) -> String {
        print("say method")
        let utterance = AVSpeechUtterance(string: line)
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        speechSynthesizer.speak(utterance)
        
  
        // wait so that the speaking starts
        Thread.sleep(forTimeInterval: 0.4)
        
        // wait until speaking is over (TODO: timeout based on line length)
        while(speechSynthesizer.isSpeaking) {
            Thread.sleep(forTimeInterval: 0.2)
        }

        
        print("speaking is over")
        
        return "return_value"
    }
    
    
    func shout(_ line: String, filter2: String, pitch: Double) {
        let utterance = AVSpeechUtterance(string: line)
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        speechSynthesizer.speak(utterance)
        
        // wait so that the speaking starts
        Thread.sleep(forTimeInterval: 0.1)
        
        // wait until speaking is over (TODO: timeout based on line length)
        while(speechSynthesizer.isSpeaking) {
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
    
    // optional, called when speaking is over
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance)
    {
        print("LOPPU")
    }
    
}
