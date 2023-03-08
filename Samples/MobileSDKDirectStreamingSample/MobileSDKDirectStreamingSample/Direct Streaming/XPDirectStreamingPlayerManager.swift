//
//  XPDirectStreamingManager.swift
//  XProtect
//
//  Created by BGMAC-PPE-01 on 21.01.20.
//  Copyright © 2020 Milestone Systems A/S. All rights reserved.
//

import Foundation
import MIPSDKMobile
import AVFoundation

@objc protocol XPDirectStreamingPlayerProtocol {
    func switchToTranscoding()
}

@objcMembers
class XPDirectStreamingPlayerManager : NSObject {
    
    var player: AVQueuePlayer!
    private var videoData = XPDirectStreamingVideoFilesManager()
    weak var delegate : XPDirectStreamingPlayerProtocol?
    var videosFolderName = XPDirectStreamingConstants.defaultVideosFolderName
    var supportsDirectStreaming = false
    var timer : Timer?
    
    // number of gaps for intervalForGatheringGapMetrics secs
    private var gapCounter: UInt = 0
    // accumulated gap time for all intervals in intervalForGatheringGapMetrics secs
    private var accumulatedGapTime = 0.0
    private var lastGapStartDate: NSDate?
    
    override init() {
        super.init()
        
        recreatePlayer()
    }
    
    convenience init(delegate: XPDirectStreamingPlayerProtocol? = nil, supportsDirectStreaming: Bool = false) {
        self.init()
        
        self.delegate = delegate
        self.supportsDirectStreaming = supportsDirectStreaming
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        player.removeObserver(self, forKeyPath: XPDirectStreamingConstants.playerTimeControlStatusKey)
    }
    
    @discardableResult func recreatePlayer() -> AVPlayer? {
        player = AVQueuePlayer()
        player.rate = 1.0
        player.automaticallyWaitsToMinimizeStalling = false
        player.actionAtItemEnd = .advance
        player.addObserver(self, forKeyPath: XPDirectStreamingConstants.playerTimeControlStatusKey, options: .new, context: nil)
        
        return player
    }
    
    // MARK: - AVPlayer observers
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == XPDirectStreamingConstants.playerTimeControlStatusKey {
            if player.timeControlStatus == .playing {
                accumulatedGapTime -= lastGapStartDate?.timeIntervalSinceNow ?? 0.0
                lastGapStartDate = nil
            } else if player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                gapCounter += 1
                lastGapStartDate = NSDate()
            }
        }
    }
    
    // MARK: - Receive video
    func videoWasReceived(_ data: Data) {
        let data2 = NSData(data: data)
        guard let videoUrl = videoData.saveVideoData(data: data2, to: videosFolderName) else {
            return
        }
        
        let asset = AVAsset(url: videoUrl)
        let avPlayerItem = AVPlayerItem(asset: asset)
        
        if player.canInsert(avPlayerItem, after: nil) {
            player.insert(avPlayerItem, after: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(finishPlayingVideoItem(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayerItem)
    }
    
    func finishPlayingVideoItem(notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem else {
            return
        }
        videoData.deleteLocalFileForPlayerItem(item: playerItem)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    // MARK: - Timer implementation

    func stopDirectStreamingTimer() {
        timer?.invalidate()
        timer = nil
        resetGapTimer()
    }
    
    func startDirectStreamingTimer() {
        if timer != nil {
            stopDirectStreamingTimer()
        }
        
        resetGapTimer(NSDate())
        
        timer = Timer.scheduledTimer(withTimeInterval: XPDirectStreamingConstants.intervalForGatheringGapMetrics, repeats: true) { [weak self] (timer) in
            guard let weakSelf = self else {
                return
            }
            
            if weakSelf.supportsDirectStreaming {
                weakSelf.gapTimerFired(timer)
            } else {
                timer.invalidate()
            }
        }
    }
    
    func resetGapTimer(_ date: NSDate? = nil) {
        gapCounter = 0
        accumulatedGapTime = 0.0
        lastGapStartDate = date
    }
    
    func gapTimerFired(_ timer: Timer) {
        if let gapStartDate = lastGapStartDate {
            accumulatedGapTime -= gapStartDate.timeIntervalSinceNow
        }
        
        if (gapCounter > XPDirectStreamingConstants.maxNumberOfGaps || accumulatedGapTime > XPDirectStreamingConstants.maxAccumulatedGapTime) {
            // switch to transcoding
            supportsDirectStreaming = false
            self.delegate?.switchToTranscoding()
            deleteAllVideos()
        }
        
        resetGapTimer(NSDate())
    }
    
    // MARK: - Delete videos
    
    func deleteAllVideos() {
        videoData.deleteDirectoryWithName(directoryName: videosFolderName)
    }
    
    // MARK: - Snapshot
    
    func snapshotImage() -> UIImage? {
        var snapshot: UIImage?
        if let asset = player.currentItem?.asset, let currentTime = player.currentItem?.currentTime() {
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            do {
                let imageRef = try imageGenerator.copyCGImage(at: currentTime, actualTime: nil)
                snapshot = UIImage(cgImage: imageRef)
            } catch let error as NSError {
                debugPrint("creating a snapshot failed: \(error)")
            }
        }
        
        return snapshot
    }
}

