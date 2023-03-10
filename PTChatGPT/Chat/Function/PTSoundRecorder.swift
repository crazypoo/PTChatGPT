//
//  PTSoundRecorder.swift
//  PTChatGPT
//
//  Created by 邓杰豪 on 12/3/23.
//  Copyright © 2023 SexyBoy. All rights reserved.
//

import UIKit
import AVFoundation

class PTSoundRecorder: NSObject,AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    var onUpdate: (([Float]) -> Void)?
    var soundSamples = [Float]()
    var levelTimer:Timer?
    
    func start() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: URL(fileURLWithPath: "/dev/null"), settings: settings)
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            
            soundSamples.removeAll()
            startTimer()
            
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
        }
    }

    func stop() {
        audioRecorder.stop()
        stopTimer()
    }
    
    func startTimer() {
        let interval:Double = 0.05
//        let bufferLength = AVAudioFrameCount(interval * (audioRecorder.settings[AVSampleRateKey] as! Double))
        
        audioRecorder.record(forDuration: interval)
        
        levelTimer = Timer(timeInterval: interval, repeats: true, block: { [weak self] _ in
            self?.audioRecorder.updateMeters()
            let decibels = self?.audioRecorder.averagePower(forChannel: 0) ?? -160
            let normalizedValue = pow(10, decibels / 20)
            self?.soundSamples.append(normalizedValue)
            self?.onUpdate?(self?.soundSamples ?? [])
            self?.audioRecorder.record(forDuration: interval)
        })
        
        RunLoop.current.add(levelTimer!, forMode: .default)
    }
    
    func stopTimer() {
        onUpdate?(soundSamples)
        soundSamples.removeAll()
        levelTimer?.invalidate()
    }

}
