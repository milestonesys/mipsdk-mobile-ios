//
//  CameraViewController.swift
//  MobileSDKVideoPushSample
//
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import AVFoundation
import UIKit
import MIPSDKMobile

class CameraViewController: UIViewController {
    
    @IBOutlet weak var photoImgView: UIImageView!
    @IBOutlet weak var startVideoButton: UIButton!
    @IBOutlet weak var startAudioButton: UIButton!
    @IBOutlet weak var noCameraAvailableLabel: UILabel!
    
    let captureSession = AVCaptureSession()
    var previewLayer: CALayer!
    var upstreamVideoConnection: XPSDKUpstreamVideoConnection?
    var streamId: String?
    var currentOrientation = UIInterfaceOrientation.unknown
    
    
    // MARK: Life cycle methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCurrentStream()
    }
    
    // MARK: IBAction methods
    @IBAction func startVideoButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            startCurrentCameraStream()
        } else {
            stopCurrentStream()
        }
    }
    
    @IBAction func startAudioButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            startAudioPush()
        } else {
            stopAudioPush()
        }
    }
    
    // MARK: Helper methods
    private func prepareCamera() {
        if #available(iOS 13.0, *) {
            currentOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.unknown
        } else {
            currentOrientation = UIInterfaceOrientation.unknown
        }
        
        captureSession.sessionPreset = .photo
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: AVMediaType.video,
                                                                position: .back).devices
        if let captureDevice = availableDevices.first {
            beginSession(device: captureDevice)
        } else {
            noCameraAvailableLabel.isHidden = false
        }
    }
    
    private func beginSession(device: AVCaptureDevice) {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        previewLayer = videoPreviewLayer
        previewLayer.frame = view.frame
        photoImgView.layer.addSublayer(previewLayer)
        captureSession.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value:kCVPixelFormatType_32BGRA)] as [String: Any]
        
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        
        captureSession.commitConfiguration()
        
        let queue = DispatchQueue(label: Constants.startStreamBufferQueue)
        dataOutput.setSampleBufferDelegate(self, queue: queue)
    }

    private func startCurrentCameraStream() {
        XPMobileSDK.requestStream(forCameraID: nil,
                                  size: CGSize(width: 640.0, height: 480.0),
                                  method: XPSDKVideoConnectionMethodPull,
                                  signal: XPSDKVideoConnectionSignalUpload,
                                  fps: 10,
                                  compressionLevel: 70,
                                  userInitiatedDownsampling: false,
                                  keyFramesOnly: false,
                                  resizeSupported: false,
                                  time: nil,
                                  upstreamImageQuality: 0.6,
                                  closeConnectionOnError: Constants.startStreamParamCloseConnectionOnError,
                                  successHandler: { [weak self] (response, connection) in
                                    guard let streamId = response.parameters?[Constants.Parameters.streamId] as? String, let videoConnection = connection as? XPSDKUpstreamVideoConnection else { return }
                                    self?.streamId = streamId
                                    self?.upstreamVideoConnection = videoConnection
                                    self?.upstreamVideoConnection?.open()
                                    self?.startAudioPush()
        }) { [weak self] (error) in
            let alert = UIAlertController(title: Constants.startStreamAlertTitle,
                                          message: nil,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.startStreamAlertOK,
                                          style: .default,
                                          handler: nil))
            self?.present(alert, animated: true)
            
            self?.stopCurrentStream()
        }
    }
    
    private func stopCurrentStream() {
        guard let videoConnection = upstreamVideoConnection else { return }
        XPMobileSDK.closeVideoConnection(videoConnection: videoConnection,
                                         successHandler: nil,
                                         failureHandler: nil)
        stopAudioPush()
        startVideoButton.isSelected = false
    }
    
    private func startAudioPush() {
        guard let streamIdUnwrapped = streamId else { return }
        XPAudioPushManager.sharedInstance.startAudioPush(forItemId: streamIdUnwrapped)
    }
    
    private func stopAudioPush() {
        XPAudioPushManager.sharedInstance.stopAudioPush()
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              upstreamVideoConnection?.isOpened == true,
              upstreamVideoConnection?.readyForMoreData == true else { return }
        upstreamVideoConnection?.upload(from: imageBuffer,
                                        forCurrentOrientation: currentOrientation,
                                        andVideoDeviceIndex: 0)
    }
}
