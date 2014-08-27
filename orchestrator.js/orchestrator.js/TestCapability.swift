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
class TestCapability : NSObject
{
    let speechSynthesizer = AVSpeechSynthesizer()
    
    override init() {
        
    }
    
    
    func test() {
        println("test method")
        let line = "moikka"
        let utterance = AVSpeechUtterance(string: line)
        speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        speechSynthesizer.speakUtterance(utterance)
    }
    
    
    func say(line: String, filter: String, pitch: Double) {
        println("say method")
        let utterance = AVSpeechUtterance(string: line)
        speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        speechSynthesizer.speakUtterance(utterance)
    }

    
    func shout(line: String, filter: String, pitch: Double) {
        let utterance = AVSpeechUtterance(string: line)
        speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        speechSynthesizer.speakUtterance(utterance)
    }

    
}