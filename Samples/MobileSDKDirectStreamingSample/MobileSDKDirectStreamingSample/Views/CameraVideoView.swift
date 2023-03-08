//
//  CameraVideoView.swift
//  MobileSDKDirectStreamingSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import UIKit
import MIPSDKMobile

@objc protocol CameraVideoViewDelegate: NSObjectProtocol {
    func cameraVideoViewReceivedFirstFrame(_ cameraVideoView: CameraVideoView)
    func cameraVideoViewLostConnection(_ cameraVideoView: CameraVideoView)
    func cameraVideoViewRestoredConnection(_ cameraVideoView: CameraVideoView)
    func cameraVideoViewReceivedResolutionChange(_ cameraVideoView: CameraVideoView)
    func cameraVideoViewDatabaseStartReached(_ cameraVideoView: CameraVideoView)
    func cameraVideoViewDatabaseEndReached(_ cameraVideoView: CameraVideoView)
    func cameraVideoViewDatabaseError(_ cameraVideoView: CameraVideoView)
    // Switch to transcoding from direct streaming
    @objc optional func cameraVideoViewSwitchToTranscoding(_ cameraVideoView: CameraVideoView)
}

class CameraVideoView: UIView {
    weak var delegate: CameraVideoViewDelegate?
    var videoConnection: XPSDKDownstreamVideoConnection?
    var lastFrame: XPSDKVideoConnectionFrame?
    var videoID = XPSDKVideoID()
    var originalRect = CGRect.zero
    var waitingFirstFrame = false
    var loadingIndicator: UIActivityIndicatorView?
    var errorMessageLabel: UILabel?
    var lostConnection = false
    
    var videoContainerView: XPVideoPlayerContainerView!
    var directStreamingManager: XPDirectStreamingPlayerManager?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func showErrorMessage(_ errorMessage: String) {
        if errorMessage == Constants.emptyString {
            errorMessageLabel?.removeFromSuperview()
        } else {
            if errorMessageLabel == nil {
                setupErrorLabel()
            }
            errorMessageLabel?.text = errorMessage
            setLoadingIndicatorVisible(false)
        }
    }
    
    // MARK: Helper methods
    private func setup() {
        setupDirectStreaming()
        
        isOpaque = false
        backgroundColor = .clear
        contentMode = .center
        
        loadingIndicator = UIActivityIndicatorView(frame: Constants.loadingIndicatorFrame)
        loadingIndicator?.center = center
        loadingIndicator?.hidesWhenStopped = true
        if let loadingIndicator = loadingIndicator {
            addSubview(loadingIndicator)
        }
        setLoadingIndicatorVisible(true)
    }
    
    private func setLoadingIndicatorVisible(_ visible: Bool) {
        if visible {
            loadingIndicator?.startAnimating()
        } else {
            loadingIndicator?.stopAnimating()
        }
    }
    
    private func setupErrorLabel() {
        let errorMessageLabel = UILabel(frame: bounds)
        errorMessageLabel.font = UIFont.systemFont(ofSize: 14)
        errorMessageLabel.textAlignment = .center
        errorMessageLabel.numberOfLines = 0
        errorMessageLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(errorMessageLabel)
        self.errorMessageLabel = errorMessageLabel
    }
    
    private func onLostConnection() {
        showErrorMessage(Constants.ErrorHandler.connectionLostMessage)
        delegate?.cameraVideoViewLostConnection(self)
        
        lostConnection = true
        
        if waitingFirstFrame {
            delegate?.cameraVideoViewReceivedFirstFrame(self)
            waitingFirstFrame = false
        }
    }
}

//MARK: XPSDKVideoConnectionDelegate methods
extension CameraVideoView: XPSDKVideoConnectionDelegate {
    func videoConnection(_ videoConnection: XPSDKDownstreamVideoConnection,
                         receivedResponse headers: [Any]) {
        print(Constants.videoConnectionReceivedResponse)
        waitingFirstFrame = true
    }
    
    func videoConnection(_ vc: XPSDKDownstreamVideoConnection,
                         receivedFrame frame: XPSDKVideoConnectionFrame) {
        setLoadingIndicatorVisible(false)
        lastFrame = frame
        
        if let dataLength = lastFrame?.videoData?.count, dataLength > 0, let videoData = lastFrame?.videoData {
            directStreamingManager?.videoWasReceived(videoData)
        } else {
            // update sourceSize according to frame and display frame.image
        }
    }
    
    func videoConnection(_ vc: XPSDKDownstreamVideoConnection,
                         receivedHeadersFor frame: XPSDKVideoConnectionFrame) {
        if !lostConnection && (frame.currentLiveEvents & XPSDKVideoConnectionFrameCameraConnectionLost.rawValue) != 0 {
            onLostConnection()
        }
    }
    
    func videoConnection(_ videoConnection: XPSDKDownstreamVideoConnection,
                         failedWithError error:Error)  {
        showErrorMessage(Constants.ErrorHandler.connectionLostMessage)
        setLoadingIndicatorVisible(false)
        delegate?.cameraVideoViewLostConnection(self)
    }
    
    func videoConnectionFinished(_ vc: XPSDKDownstreamVideoConnection) {
        videoConnection = nil
        videoID = Constants.emptyString as XPSDKVideoID
    }
    
    // MARK: - setup direct streaming views
    private func setupDirectStreaming() {
        directStreamingManager = XPDirectStreamingPlayerManager(delegate: self, supportsDirectStreaming: true)
        
        guard let player = directStreamingManager?.player else {
            return
        }
        
        videoContainerView = XPVideoPlayerContainerView(frame: .zero, player: player, playerLayerFrame: bounds)
        addSubview(videoContainerView)
    }
    
    func recreateDirectStreamingPlayer() {
        guard let player =  directStreamingManager?.recreatePlayer() else { return }
        videoContainerView.setupPlayer(player, playerLayerFrame: .zero)
    }
}

// MARK: - XPDirectStreamingPlayerProtocol methods
extension CameraVideoView: XPDirectStreamingPlayerProtocol {
    public func switchToTranscoding() {
        // switch to transcoding and show the frame's image if there is a problem with the direct streaming video
        delegate?.cameraVideoViewSwitchToTranscoding?(self)
    }
}
