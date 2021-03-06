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
    @objc let speechSynthesizer = AVSpeechSynthesizer()
    
    
    override init() {
        super.init()
        print("iitu")
        //speechSynthesizer.delegate = self

    }
    
    @objc func initMeasurement() {
        print("init measurement")
    }
    
    @objc func calculateAverage() {
        print("calculate average")
    }
    
    
    @objc func dummyMethod() {
        print("Dummy")
    }
    
    
    
    
    
    @objc func test() -> String {
        print("test method")
        //let line = "moikka"
        //let utterance = AVSpeechUtterance(string: line)
        //speechSynthesizer.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        //speechSynthesizer.speakUtterance(utterance)
        return "foobar"
    }
    
    @objc func say(_ line: String, filter: String, pitch: String) {
        print("say method")
        let utterance = AVSpeechUtterance(string: line)
        /*
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        speechSynthesizer.speak(utterance)
        
        // wait so that the speaking starts
        Thread.sleep(forTimeInterval: 0.1)

        // wait until speaking is over (TODO: timeout based on line length)
        while(speechSynthesizer.isSpeaking) {
            Thread.sleep(forTimeInterval: 0.2)
        }
 */
        print("speaking is over")
    }

    
    @objc func shout(_ line: String, filter2: String, pitch: Double) {
        let utterance = AVSpeechUtterance(string: line)
        /*
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        speechSynthesizer.speak(utterance)
        
        // wait so that the speaking starts
        Thread.sleep(forTimeInterval: 0.1)
        
        // wait until speaking is over (TODO: timeout based on line length)
        while(speechSynthesizer.isSpeaking) {
            Thread.sleep(forTimeInterval: 0.2)
        }
 */
    }
    
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance)
    {
        print("LOPPU")
    }

    
    
    
}
