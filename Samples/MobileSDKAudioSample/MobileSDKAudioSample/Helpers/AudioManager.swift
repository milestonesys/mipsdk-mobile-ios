//
//  AudioManager.swift
//  MobileSDKAudioSample
//
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import Foundation
import AVFoundation
import MIPSDKMobile


@objc public protocol AudioManagerDelegate {
    func didGetErrorWhilePlayingAudio(error: NSError)
    @objc optional func bufferingAudio()
    @objc optional func stopBufferingAudio()
}

open class AudioManager: NSObject {
    @objc static let sharedInstance = AudioManager()
    @objc weak var delegate: AudioManagerDelegate?
    
    var audioPlayer = AVPlayer()
    
    var audioId: String?
    var isStoppedIntentionally = false
    var shouldStartTimer = false
    
    
    //MARK: Init and Deinit methods
    private override init() {
        super.init()
        
        createPlayer()
        NotificationCenter.default.addObserver(self, selector: #selector(itemPlaybackStalled), name: .AVPlayerItemPlaybackStalled, object: nil)
    }
    
    deinit {
        audioPlayer.removeObserver(self, forKeyPath: Constants.audioTimeControlStatus, context: nil)
    }

    //MARK: Audio methods
    @objc public func playAudio(withItemId itemId: String,
                                playbackControllerId: String?,
                                investigationId: String?,
                                signalType: String) {
        XPMobileSDK.requestAudioStream(forMicrophoneId: itemId,
                                       playbackControllerId: playbackControllerId,
                                       investigationId: investigationId,
                                       audioEncoding: Constants.audioEncoding,
                                       signalType: signalType.description,
                                       methodType: Constants.audioMethodType,
                                       successHandler: { [weak self] (response) in
            guard let response = response else { return }
            self?.requestAudioSuccessHandler(response)
        }) { [weak self] (error) in
            guard let error = error else { return }
            self?.requestAudioFailureHandler(error)
        }
    }
    
    @objc public func stopAudio() {
        audioPlayer.currentItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        isStoppedIntentionally = true
        if let id = audioId {
            XPMobileSDK.closeAudioStream(forAudioId: id, successHandler: nil, failureHandler: nil)
        }
        audioPlayer.pause()
    }
    
    override open func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey : Any]?,
                                    context: UnsafeMutableRawPointer?) {
        if keyPath == Constants.audioTimeControlStatus {
            if audioPlayer.timeControlStatus == .paused{
                // Audio is paused
                handleAudioNotPlaying()
            } else if audioPlayer.timeControlStatus == .playing {
                // Audio is playing
                delegate?.stopBufferingAudio?()
            } else if convertFromOptionalAVPlayerWaitingReason(audioPlayer.reasonForWaitingToPlay) == convertFromAVPlayerWaitingReason(AVPlayer.WaitingReason.noItemToPlay) {
                // Reason for waiting to play: \(String(describing: convertFromOptionalAVPlayerWaitingReason(audioPlayer.reasonForWaitingToPlay)))
                handleAudioNotPlaying()
            }
            else { //Waiting to play at specified rate
                // Reason for waiting to play: \(String(describing: convertFromOptionalAVPlayerWaitingReason(audioPlayer.reasonForWaitingToPlay)))
            }
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            var status: AVPlayerItem.Status = .unknown
            
            // Get the status change from the change dictionary
            if let statusNumber = change?[.newKey] as? NSNumber,
               let playerStatus = AVPlayerItem.Status(rawValue: statusNumber.intValue) {
                status = playerStatus
            }
            
            // Switch over the status
            switch status {
            case .readyToPlay:
                // Player item is ready to play.
                delegate?.stopBufferingAudio?()
            case .failed:
                // Player item failed. See error.
                let error = NSError(domain: Constants.ErrorHandler.audioErrorMessage, code: Constants.ErrorHandler.audioError, userInfo: nil)
                delegate?.stopBufferingAudio?()
                delegate?.didGetErrorWhilePlayingAudio(error: error)
            case .unknown:
                // Player item is not yet ready.
                delegate?.bufferingAudio?()
            @unknown default:
                break
            }
        }
    }
    
    //MARK: Helper methods
    private func handleAudioNotPlaying() {
        if !isStoppedIntentionally && shouldStartTimer {
            shouldStartTimer = false
            perform(#selector(playAfterStalling), with: nil, afterDelay: 5.0)
        }
    }
    
    @objc private func itemPlaybackStalled() {
        let error = NSError(domain: Constants.ErrorHandler.audioErrorMessage,
                            code: Constants.ErrorHandler.audioError,
                            userInfo: nil)
        delegate?.stopBufferingAudio?()
        delegate?.didGetErrorWhilePlayingAudio(error: error)
    }
    
    @objc private func playAfterStalling() {
        if audioPlayer.timeControlStatus == .playing && audioPlayer.currentTime().value > 0 {
            shouldStartTimer = true
            return
        }
        if !isStoppedIntentionally {
            itemPlaybackStalled()
        }
    }
    
    private func createPlayer() {
        audioPlayer.automaticallyWaitsToMinimizeStalling = false
        audioPlayer.addObserver(self, forKeyPath: Constants.audioTimeControlStatus,
                                options: NSKeyValueObservingOptions(), context: nil)
    }
    
    @objc private func playAudioAfterDelay() {
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                         mode: .default,
                                                         options: [.mixWithOthers, .defaultToSpeaker])
        
        shouldStartTimer = true
        audioPlayer.playImmediately(atRate: 1.0)
    }

    private func playAudio(forURL audioURL: String) {
        shouldStartTimer = true
        
        guard let url = URL(string: audioURL) else { return }
        let playerItem = AVPlayerItem(url: url)
        
        audioPlayer.replaceCurrentItem(with: playerItem)
        audioPlayer.currentItem?.addObserver(self,
                                             forKeyPath: #keyPath(AVPlayerItem.status),
                                             options: [.old, .new],
                                             context: nil)
        perform(#selector(playAudioAfterDelay), with: nil, afterDelay: 0.8)
    }
    
    private func requestAudioSuccessHandler(_ response: XPSDKResponse) {
        let url = XPSDKConnection.sharedConnection.url
        let outputParameters = response.parameters
        
        guard let urlProtocol = url?.scheme,
              let host = url?.host,
              let port = url?.port,
              let audioIdentifier = outputParameters?[Constants.ResponseItem.videoId] as? String,
              let serviceAlias = XPSDKConnection.sharedConnection.serverInfo?.serviceAlias else {
            return
        }
        
        audioId = audioIdentifier
        let audioURL = String(format: Constants.audioUrl, serviceAlias, audioIdentifier)
        let fullURL = String(format: Constants.fullUrl, urlProtocol, host, port, audioURL)
        isStoppedIntentionally = false
        playAudio(forURL: fullURL)
    }
    
    private func requestAudioFailureHandler(_ error: NSError) {
        shouldStartTimer = false
        delegate?.didGetErrorWhilePlayingAudio(error: error)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromOptionalAVPlayerWaitingReason(_ input: AVPlayer.WaitingReason?) -> String? {
    guard let input = input else { return nil }
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVPlayerWaitingReason(_ input: AVPlayer.WaitingReason) -> String {
    return input.rawValue
}
