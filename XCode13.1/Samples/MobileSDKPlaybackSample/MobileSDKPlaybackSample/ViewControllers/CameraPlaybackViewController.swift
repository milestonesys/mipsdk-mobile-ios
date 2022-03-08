/*
 CameraPlaybackViewController.swift
 
 View controller for video playback interface
 */

import UIKit
import MIPSDKMobile

class CameraPlaybackViewController: UIViewController {
    enum CameraPlaybackPlaying: Int {
        case None = 0
        case Forward = 1
        case Backwards = -1
        
        func playSpeed() -> Float {
            switch self {
            case .None:
                return 0.0
            case .Forward:
                return 1.0
            case .Backwards:
                return -1.0
            }
        }
    }

    @IBOutlet weak var toolbar: UIToolbar!

    var cameraID: XPSDKViewID?
    var cameraName: String?
    var cameraVideoView: CameraVideoView?
    var playing: CameraPlaybackPlaying = .None
    var playSpeed: Float = 1.0
    
    
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
                                  size: Constants.RequestStreamParameters.size,
                                  method: XPSDKVideoConnectionMethodPush,
                                  signal: XPSDKVideoConnectionSignalPlayback,
                                  fps: Constants.RequestStreamParameters.fps,
                                  compressionLevel: Constants.RequestStreamParameters.compressionLevel,
                                  userInitiatedDownsampling: false,
                                  keyFramesOnly: false,
                                  resizeSupported: true,
                                  time: NSDate(),
                                  upstreamImageQuality: Constants.RequestStreamParameters.upstreamVideoQuality,
                                  closeConnectionOnError: Constants.RequestStreamParameters.closeConnectionOnError,
                                  successHandler: { [weak self] (_ response: XPSDKResponse, _ videoConnection: XPSDKVideoConnection) -> Void in
                                    self?.setupCameraVideoView(videoConnection: videoConnection)
        }, failureHandler: nil)
    }
    
    private func closeStream() {
        guard let videoConnection = cameraVideoView?.videoConnection else { return }
        
        XPMobileSDK.closeVideoConnection(videoConnection: videoConnection,
                                         successHandler: { [weak self] (_ response: XPSDKResponse!) in
                                            print(Constants.videoConnectionClosingMessage)
                                            self?.cameraVideoView?.videoConnection = nil
                                            
        }, failureHandler: { [weak self]  (error:NSError?) in
            print(Constants.ErrorHandler.videoConnectionClosingErrorMessage)
            self?.cameraVideoView?.videoConnection = nil
        })
    }
    
    //MARK: IBActions
    @IBAction func backwards(_ sender: Any) {
        play(direction: .Backwards)
    }
    
    @IBAction func pause(_ sender: Any) {
        play(direction: .None)
    }
    
    @IBAction func forward(_ sender: Any) {
        play(direction: .Forward)
    }
    
    //MARK: Helper methods
    private func setup() {
        title = cameraName;
        startCurrentCameraStream()
    }
    
    private func play(direction: CameraPlaybackPlaying) {
        if playing != direction {
            playing = direction
            let speed = direction.playSpeed()
            if let videoID = cameraVideoView?.videoConnection?.videoID {
                XPMobileSDK.changeStream(forVideoID: videoID,
                                         playSpeed: speed,
                                         successHandler: nil,
                                         failureHandler: nil)
            }
        }
    }
    
    private func setupCameraVideoView(videoConnection: XPSDKVideoConnection) {
        guard let downstreamVideoConnection = videoConnection as? XPSDKDownstreamVideoConnection else { return }
        
        let videoViewFrame = CGRect(x: 0,
                                    y: 0,
                                    width: view.bounds.width,
                                    height: view.bounds.height - (navigationController?.navigationBar.frame.size.height ?? 0.0) - toolbar.frame.size.height)
        let cameraVideoView = CameraVideoView(frame: videoViewFrame)
        cameraVideoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cameraVideoView.delegate = self
        cameraVideoView.videoConnection = downstreamVideoConnection
        view.addSubview(cameraVideoView)
        self.cameraVideoView = cameraVideoView
        
        downstreamVideoConnection.delegate = cameraVideoView
        downstreamVideoConnection.open()
    }
}

//MARK: CameraVideoViewDelegate methods
extension CameraPlaybackViewController: CameraVideoViewDelegate {
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
