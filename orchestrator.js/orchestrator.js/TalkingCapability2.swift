//
//  TalkingCapability.swift
//  orchestrator.js
//
//  Created by Niko Mäkitalo on 27.8.2014.
//  Copyright (c) 2014 Niko Mäkitalo. All rights reserved.
//

import Foundation
import AVFoundation


@objc
class TalkingCapability2 : NSObject
{
    let speechSynthesizer = AVSpeechSynthesizer()
    
    override init() {
        
    }
    
    func test() {
        print("test method")
        let line = "moikka"
        let utterance = AVSpeechUtterance(string: line)
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        speechSynthesizer.speak(utterance)
    }
    
    func say(_ line: String, filter: String, pitch: Double) {
        print("say method")
        let utterance = AVSpeechUtterance(string: line)
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        speechSynthesizer.speak(utterance)
    }

    
    func shout(_ line: String, filter: String, pitch: Double) {
        let utterance = AVSpeechUtterance(string: line)
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        speechSynthesizer.speak(utterance)
    }

    
}
