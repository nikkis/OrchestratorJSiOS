//
//  TestCapability.swift
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 27.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

import Foundation
import AVFoundation

@objc
class TestCapability : NSObject, AVSpeechSynthesizerDelegate
{
    let speechSynthesizer = AVSpeechSynthesizer()
    
    
    override init() {
        super.init()
        speechSynthesizer.delegate = self

    }
    
    
    func test() {
        println("test method")
        let line = "moikka"
        let utterance = AVSpeechUtterance(string: line)
        speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        speechSynthesizer.speakUtterance(utterance)
    }
    
    func say(line: String, filter: String, pitch: String) {
        println("say method")
        let utterance = AVSpeechUtterance(string: line)
        speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        speechSynthesizer.speakUtterance(utterance)
        
        // wait so that the speaking starts
        NSThread.sleepForTimeInterval(0.1)

        // wait until speaking is over (TODO: timeout based on line length)
        while(speechSynthesizer.speaking) {
            NSThread.sleepForTimeInterval(0.2)
        }
        println("speaking is over")
    }

    
    func shout(line: String, filter2: String, pitch: Double) {
        let utterance = AVSpeechUtterance(string: line)
        speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        speechSynthesizer.speakUtterance(utterance)
        
        // wait so that the speaking starts
        NSThread.sleepForTimeInterval(0.1)
        
        // wait until speaking is over (TODO: timeout based on line length)
        while(speechSynthesizer.speaking) {
            NSThread.sleepForTimeInterval(0.2)
        }
    }
    
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer!,
        didFinishSpeechUtterance utterance: AVSpeechUtterance!)
    {
        println("LOPPU SLUT")
    }

    
    
    
}