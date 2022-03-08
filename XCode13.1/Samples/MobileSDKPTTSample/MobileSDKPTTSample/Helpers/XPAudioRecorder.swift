//
//  XPAudioRecorder.swift
//  MobileSDKPTTSample
//
//  This is a Swift 3.0 class
//  that uses the iOS RemoteIO Audio Unit
//  to record audio input samples,
//  (should be instantiated as a singleton object.)
//
//  Based on the RecordAudio class created by Ronald Nicholson on 10/21/16.  Updated 2017Feb07
//  Copyright © 2017 HotPaw Productions. All rights reserved.
//  Distribution: BSD 2-clause license
//
import Foundation
import AVFoundation
import AudioUnit
import MIPSDKMobile

open class XPAudioRecorder: NSObject {
    
    var audioUnit: AudioUnit?
    
    var sessionActive =  false
    var isRecording =  false
    var sampleRate : Double = 8000
    let bufferSize = 2048
    var buffer = [Int16](repeating: 0, count: 2048)  // for incoming samples
    var bufferIndex : Int =  0
    
    private var interrupted = false     // for restart from audio interruption notification
    static let sharedInstance = XPAudioRecorder()
    
    func startRecording() {
        if isRecording { return }
        resetBuffer()
        isRecording = true
        checkForMicrophonePermission()
        if sessionActive {
            startAudioUnit()
        }
    }
    
    private let outputBus: UInt32 = 0
    private let inputBus: UInt32 = 1
    
    private func startAudioUnit() {
        var err: OSStatus = noErr
        
        if audioUnit == nil {
            setupAudioUnit()
        }
        guard let au = audioUnit else {
            isRecording = false
            return
        }
        
        err = AudioUnitInitialize(au)
        if err != noErr {
            isRecording = false
            return
        }
        err = AudioOutputUnitStart(au)
        
        if err != noErr {
            isRecording = false
        }
    }
    
    private func checkForMicrophonePermission() {
        if (sessionActive == false) {
            switch AVAudioSession.sharedInstance().recordPermission {
            case AVAudioSession.RecordPermission.granted:
                startAudioSession()
            case AVAudioSession.RecordPermission.denied:
                isRecording = false
                if let audioPushDelegate = XPAudioPushManager.sharedInstance.delegate {
                    audioPushDelegate.microphoneUsageNotAllowed()
                }
                return
            case AVAudioSession.RecordPermission.undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                    DispatchQueue.main.async { [weak self] in
                        if granted {
                            self?.startAudioSession()
                        } else {
                            self?.isRecording = false
                            if let audioPushDelegate = XPAudioPushManager.sharedInstance.delegate {
                                audioPushDelegate.microphoneUsageNotAllowed()
                            }
                            return
                        }
                    }
                    
                })
            default:
                break
            }
        }
    }
    
    private func startAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [.mixWithOthers, .defaultToSpeaker])
            let preferredIOBufferDuration = 0.0058
            let desiredSampleRate = sampleRate
            try audioSession.setPreferredSampleRate(desiredSampleRate)
            try audioSession.setPreferredIOBufferDuration(preferredIOBufferDuration)
            
            NotificationCenter.default.addObserver(
                forName: AVAudioSession.interruptionNotification,
                object: nil,
                queue: nil,
                using: audioSessionInterruptionHandler )
            
            try audioSession.setActive(true)
            sessionActive = true
            try audioSession.setPreferredSampleRate(desiredSampleRate)
            print("\(audioSession.sampleRate)")
        } catch {
            let errorDescription = Constants.ErrorHanler.internalAudioPushError
            let error = NSError(domain: Constants.ErrorHanler.audioPushErrorDomainName,
                                code: -11111,
                                userInfo: [NSLocalizedDescriptionKey: errorDescription])
            if let audioPushDelegate = XPAudioPushManager.sharedInstance.delegate {
                audioPushDelegate.didGetErrorWhilePushingAudio(error: error)
            }
            isRecording = false
            print("Error starting audio session")
        }
    }
    
    
    private func setupAudioUnit() {
        var componentDesc:  AudioComponentDescription = AudioComponentDescription(
                componentType:          OSType(kAudioUnitType_Output),
                componentSubType:       OSType(kAudioUnitSubType_RemoteIO),
                componentManufacturer:  OSType(kAudioUnitManufacturer_Apple),
                componentFlags:         UInt32(0),
                componentFlagsMask:     UInt32(0) )
        
        var osErr: OSStatus = noErr
        
        let component: AudioComponent! = AudioComponentFindNext(nil, &componentDesc)
        
        var tempAudioUnit: AudioUnit?
        osErr = AudioComponentInstanceNew(component, &tempAudioUnit)
        audioUnit = tempAudioUnit
        
        guard let au = audioUnit
            else { return }
        
        // Enable I/O for input.
        
        var one_ui32: UInt32 = 1
        
        osErr = AudioUnitSetProperty(au,
                                     kAudioOutputUnitProperty_EnableIO,
                                     kAudioUnitScope_Input,
                                     inputBus,
                                     &one_ui32,
                                     UInt32(MemoryLayout<UInt32>.size))
        
        // Set format to 32-bit Floats, linear PCM
        let nc = 1  // 1 channel mono
        var streamFormatDesc:AudioStreamBasicDescription = AudioStreamBasicDescription(
            mSampleRate:        Double(sampleRate),
            mFormatID:          kAudioFormatLinearPCM,
            mFormatFlags:       ( kAudioFormatFlagIsSignedInteger|kLinearPCMFormatFlagIsPacked|kAudioFormatFlagsNativeEndian ),
            mBytesPerPacket:    UInt32(nc * 2),
            mFramesPerPacket:   1,
            mBytesPerFrame:     UInt32(nc * 2),
            mChannelsPerFrame:  UInt32(nc),
            mBitsPerChannel:    UInt32(2*8),
            mReserved:          UInt32(0)
        )
        
        osErr = AudioUnitSetProperty(au,
                                     kAudioUnitProperty_StreamFormat,
                                     kAudioUnitScope_Input, outputBus,
                                     &streamFormatDesc,
                                     UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        
        osErr = AudioUnitSetProperty(au,
                                     kAudioUnitProperty_StreamFormat,
                                     kAudioUnitScope_Output,
                                     inputBus,
                                     &streamFormatDesc,
                                     UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        
        var inputCallbackStruct
            = AURenderCallbackStruct(inputProc: recordingCallback,
                                     inputProcRefCon:
                UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        
        osErr = AudioUnitSetProperty(au,
                                     AudioUnitPropertyID(kAudioOutputUnitProperty_SetInputCallback),
                                     AudioUnitScope(kAudioUnitScope_Global),
                                     inputBus,
                                     &inputCallbackStruct,
                                     UInt32(MemoryLayout<AURenderCallbackStruct>.size))
        
        // Ask CoreAudio to allocate buffers on render.
        osErr = AudioUnitSetProperty(au,
                                     AudioUnitPropertyID(kAudioUnitProperty_ShouldAllocateBuffer),
                                     AudioUnitScope(kAudioUnitScope_Output),
                                     inputBus,
                                     &one_ui32,
                                     UInt32(MemoryLayout<UInt32>.size))
        if osErr != noErr {
            print("Undefined error")
        }
    }
    
    let recordingCallback: AURenderCallback = { (
        inRefCon,
        ioActionFlags,
        inTimeStamp,
        inBusNumber,
        frameCount,
        ioData ) -> OSStatus in
        
        let audioObject = unsafeBitCast(inRefCon, to: XPAudioRecorder.self)
        var err: OSStatus = noErr
        
        // set mData to nil, AudioUnitRender() should be allocating buffers
        var bufferList = AudioBufferList(
            mNumberBuffers: 1,
            mBuffers: AudioBuffer(
                mNumberChannels: UInt32(1),
                mDataByteSize: 2048,
                mData: nil))
        
        if let au = audioObject.audioUnit {
            err = AudioUnitRender(au,
                                  ioActionFlags,
                                  inTimeStamp,
                                  inBusNumber,
                                  frameCount,
                                  &bufferList)
        }
        
        audioObject.processMicrophoneBuffer(inputDataList: &bufferList,
                                            frameCount: UInt32(frameCount) )
        return 0
    }
    
    private func processMicrophoneBuffer( // process RemoteIO Buffer from mic input
        inputDataList : UnsafeMutablePointer<AudioBufferList>,
        frameCount : UInt32 )
    {
        if (!isRecording) {
            return
        }
        
        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
        let mBuffers : AudioBuffer = inputDataPtr[0]
        let count = Int(frameCount)
        let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
        
        if let bufferPointer = bufferPointer {
            let dataArray = bufferPointer.assumingMemoryBound(to: Int16.self)
            let elemSize = MemoryLayout<UInt16>.stride
            memmove(&buffer[bufferIndex], &dataArray[0], count * elemSize)
            bufferIndex+=count
        }
        
        if (bufferIndex + count > bufferSize) { //if there is no space for the next frames, then send current buffer and empty it
            pushAudioData(buffer.withUnsafeBufferPointer( { Data(buffer: $0 )} ))
            resetBuffer()
        }
        
    }
    
    func stopRecording() {
        if let audioUnit = audioUnit {
            AudioUnitUninitialize(audioUnit)
        }
        isRecording = false
    }
    
    private func audioSessionInterruptionHandler(notification: Notification) -> Void {
        let interuptionDict = notification.userInfo
        if let interuptionType = interuptionDict?[AVAudioSessionInterruptionTypeKey] {
            let interuptionVal = AVAudioSession.InterruptionType(
                rawValue: (interuptionType as AnyObject).uintValue )
            if (interuptionVal == AVAudioSession.InterruptionType.began) {
                if (isRecording) {
                    stopRecording()
                    isRecording = false
                    let audioSession = AVAudioSession.sharedInstance()
                    do {
                        try audioSession.setActive(false)
                        sessionActive = false
                    } catch {
                    }
                    interrupted = true
                }
            } else if (interuptionVal == AVAudioSession.InterruptionType.ended) {
                if (interrupted) {
                    // potentially restart here
                }
            }
        }
    }
    
    private func pushAudioData(_ audioData: Data) {
        XPAudioPushManager.sharedInstance.pushAudio(audioData)
    }
    
    func pushRemainingAudio() {
        pushAudioData(buffer.withUnsafeBufferPointer( { Data(buffer: $0 )} ))
    }
    
    private func resetBuffer() {
        buffer = [Int16](repeating: 0, count: bufferSize)
        bufferIndex = 0
    }
}
