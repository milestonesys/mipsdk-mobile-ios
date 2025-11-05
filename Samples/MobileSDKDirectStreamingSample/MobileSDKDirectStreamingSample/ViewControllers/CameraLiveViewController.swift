//
//  CameraLiveViewController.swift
//  MobileSDKDirectStreamingSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import UIKit
import MIPSDKMobile

class CameraLiveViewController: UIViewController {

    var cameraID: XPSDKViewID?
    var cameraName: String?
    var cameraVideoView: CameraVideoView?
    
    // MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeStream()
    }
    
    // MARK: Video Stream methods
    private func startCurrentCameraStream() {
        XPMobileSDK.requestStream(forCameraID: cameraID,
                                  streamType: Constants.RequestStreamParameters.streamType,
                                  size: Constants.RequestStreamParameters.size,
                                  method: XPSDKVideoConnectionMethodPush,
                                  signal: XPSDKVideoConnectionSignalLive,
                                  fps: Constants.RequestStreamParameters.fps,
                                  compressionLevel: Constants.RequestStreamParameters.compressionLevel,
                                  userInitiatedDownsampling: false,
                                  keyFramesOnly: false,
                                  resizeSupported: true,
                                  time: NSDate(),
                                  upstreamImageQuality: Constants.RequestStreamParameters.upstreamVideoQuality,
                                  closeConnectionOnError: Constants.RequestStreamParameters.closeConnectionOnError) { [weak self] response, videoConnection in
            self?.setupCameraVideoView(videoConnection: videoConnection)
        } failureHandler: { error in
            debugPrint("requestStream error: \(String(describing: error))")
        }
    }
    
    private func closeStream() {
        guard let videoConnection = cameraVideoView?.videoConnection else { return }
        
        XPMobileSDK.closeVideoConnection(videoConnection: videoConnection,
                                         successHandler: { [weak self] (_ response: XPSDKResponse!) in
                                            print(Constants.videoConnectionClosingMessage)
                                            self?.cameraVideoView?.videoConnection = nil
        }, failureHandler: { [weak self] (error:NSError?) in
            print(Constants.ErrorHandler.videoConnectionClosingErrorMessage)
            self?.cameraVideoView?.videoConnection = nil
        })
    }
    
    //MARK: Helper methods
    private func setup() {
        title = cameraName;
        startCurrentCameraStream()
    }
    
    private func setupCameraVideoView(videoConnection: XPSDKVideoConnection) {
        guard let downstreamVideoConnection = videoConnection as? XPSDKDownstreamVideoConnection else {
            return
        }
        
        let cameraView = CameraVideoView()
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.delegate = self
        cameraView.videoConnection = downstreamVideoConnection
        view.addSubview(cameraView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            cameraView.bottomAnchor.constraint(lessThanOrEqualTo: safeArea.bottomAnchor),
            cameraView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
        
        cameraVideoView = cameraView
        downstreamVideoConnection.delegate = cameraVideoView
        downstreamVideoConnection.open()
    }
}

//MARK: CameraVideoViewDelegate methods
extension CameraLiveViewController: CameraVideoViewDelegate {
    func cameraVideoViewReceivedFirstFrame(_ cameraVideoView: CameraVideoView) {}
    
    func cameraVideoViewLostConnection(_ cameraVideoView: CameraVideoView) {
        cameraVideoView.showErrorMessage(Constants.ErrorHandler.connectionLostMessage)
    }
    
    func cameraVideoViewRestoredConnection(_ cameraVideoView: CameraVideoView) {}
    
    func cameraVideoViewReceivedResolutionChange(_ cameraVideoView: CameraVideoView) {}
    
    func cameraVideoViewDatabaseStartReached(_ cameraVideoView: CameraVideoView) {}
    
    func cameraVideoViewDatabaseEndReached(_ cameraVideoView: CameraVideoView) {}
    
    func cameraVideoViewDatabaseError(_ cameraVideoView: CameraVideoView) {}
}
