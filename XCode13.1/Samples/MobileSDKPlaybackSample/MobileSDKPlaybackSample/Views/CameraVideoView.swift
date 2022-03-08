/*
 * CameraVideoView.swift
 
 * View that handles displaying video frames
 * For now, this view displays video correctly only when created programmatically
 */

import UIKit
import MIPSDKMobile

protocol CameraVideoViewDelegate: NSObjectProtocol {
    func cameraVideoViewReceivedFirstFrame(_ cameraVideoView: CameraVideoView)
    func cameraVideoViewLostConnection(_ cameraVideoView: CameraVideoView)
    func cameraVideoViewRestoredConnection(_ cameraVideoView: CameraVideoView)
    func cameraVideoViewReceivedResolutionChange(_ cameraVideoView: CameraVideoView)
    func cameraVideoViewDatabaseStartReached(_ cameraVideoView: CameraVideoView)
    func cameraVideoViewDatabaseEndReached(_ cameraVideoView: CameraVideoView)
    func cameraVideoViewDatabaseError(_ cameraVideoView: CameraVideoView)
}

class CameraVideoView: UIView {
    weak var delegate: CameraVideoViewDelegate?
    var videoConnection: XPSDKDownstreamVideoConnection?
    var lastFrame: XPSDKVideoConnectionFrame?
    var lastImage: UIImage?
    var videoID = XPSDKVideoID()
    var originalRect = CGRect.zero
    var waitingFirstFrame = false
    var loadingIndicator: UIActivityIndicatorView?
    var errorMessageLabel: UILabel?
    var lostConnection = false
    
    var imageRect: CGRect {
        guard let videoConnection = videoConnection else { return .zero }
        
        let isOrientationPortrait = UIDevice.current.orientation.isPortrait
        
        let coef = videoConnection.sourceSize.width / videoConnection.sourceSize.height
        let width = isOrientationPortrait ? bounds.size.width : bounds.size.height * coef
        let height = isOrientationPortrait ? bounds.size.width / coef : bounds.size.height
        let x = isOrientationPortrait ? 0.0 : (bounds.size.width - width) / 2.0
        let y = isOrientationPortrait ? (bounds.size.height - height) / 2.0 : 0.0
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.clear(rect)
        if let lastImage = lastImage {
            lastImage.draw(in: imageRect)
        }
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
        clearsContextBeforeDrawing = false
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
    
    private func dismissCurrentFrame() {
        if lastImage != nil {
            lastImage = nil
            setNeedsDisplay()
        }
    }
    
    private func dismissLastFrame() {
        if lastFrame != nil {
            lastFrame = nil
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
    
    private func updateLastImage(_ image: UIImage?) {
        if image != nil {
            if lostConnection {
                showErrorMessage(Constants.ErrorHandler.connectionLostMessage)
                delegate?.cameraVideoViewRestoredConnection(self)
                lostConnection = false
            }
            lastImage = image
            setNeedsDisplay()
            if waitingFirstFrame {
                delegate?.cameraVideoViewReceivedFirstFrame(self)
                isOpaque = true
                waitingFirstFrame = false
            }
        }
    }
    
    private func updateSourceSize(forFame frame: XPSDKVideoConnectionFrame) {
        if frame.hasSizeInformation, let videoConnection = videoConnection {
            originalRect = frame.sourceRect
            if !frame.sourceSize.equalTo(videoConnection.sourceSize) {
                print("\(Constants.newSizeReceivedLog) \(NSValue(cgRect: originalRect)) \(Constants.imageSizeLog) \(NSValue(cgSize: frame.image.size))")
                videoConnection.sourceSize = frame.sourceSize
                delegate?.cameraVideoViewReceivedResolutionChange(self)
            }
        }
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
        updateSourceSize(forFame: frame)
        updateLastImage(frame.image)
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
        lastImage = nil
        videoConnection = nil
        videoID = Constants.emptyString as XPSDKVideoID
    }
}
