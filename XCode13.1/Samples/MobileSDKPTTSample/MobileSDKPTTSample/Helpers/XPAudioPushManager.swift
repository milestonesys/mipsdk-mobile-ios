//
//  XPAudioPushConnection.swift
//  MobileSDKVideoPushSample
//
//  Created by Aleksandra Spirovska on 20.11.18.
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import Foundation
import MIPSDKMobile

@objc public protocol XPAudioPushManagerDelegate {
    func didGetErrorWhilePushingAudio(error: NSError)
    func microphoneUsageNotAllowed()
}

class XPAudioPushManager : NSObject {
    static let sharedInstance = XPAudioPushManager()
    weak var delegate: XPAudioPushManagerDelegate?
    
    private var fullURL: String?
    private var streamId: String?
    private var audioId: String?
    private var UUIDBytesRef: CFUUID?
    
    private var currentRequest: XPSDKRequest?
    private var isStreamOpen = false
    private var hasError = false
    
    
    public func startAudioPush(forItemId itemId: String) {
        XPAudioRecorder.sharedInstance.startRecording()
        hasError = false
        
        let successHandler: SuccessResponse = { [weak self] (response) in
            self?.audioPushSucceed(response: response)
        }
        
        let failHandler: FailureBlock = { [weak self] (error) in
            self?.audioPushFailed(error: error)
        }

        currentRequest = XPMobileSDK.requestAudioStreamIn(forItemId: itemId,
                                                          audioEncoding: Constants.RequestAudioParameters.audioEncoding,
                                                          samplingRate: Constants.RequestAudioParameters.samplingRate,
                                                          bitsPerSample: Constants.RequestAudioParameters.bitsPerSample,
                                                          numberOfChannels: Constants.RequestAudioParameters.numberOfChannels,
                                                          closeConnectionOnError: Constants.RequestAudioParameters.closeConnectionOnError,
                                                          successHandler: successHandler,
                                                          failureHandler: failHandler)
    }
    
    public func pushAudio(_ audioData: Data) {
        if !isStreamOpen || hasError {
            return
        }
        
        let frameData = createFrameData(audioData: audioData)
        
        guard let urlString = fullURL, let url = URL(string: urlString) else {
            print("Unable to request audio stream")
            return
        }
        
        let request = NSMutableURLRequest(url: url)

        request.httpMethod = Constants.RequestAudioParameters.httpMethod
        request.httpBody = frameData
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self, !weakSelf.hasError else { return }
                
                if let error = error as NSError? {
                    weakSelf.pushAudioFailed(error: error)
                } else if let httpResponse = response as? HTTPURLResponse {
                    weakSelf.pushAudioSucceed(data: data, httpResponse: httpResponse)
                }
                
                if weakSelf.hasError {
                    weakSelf.closeAudioPushStream()
                    XPAudioRecorder.sharedInstance.stopRecording()
                }
            }
        }).resume()
    }
    
    @objc public func stopAudioPush() {
        if let request = currentRequest {
            XPMobileSDK.cancelRequestStream(request: request)
            currentRequest = nil
            isStreamOpen = false
        }
        
        XPAudioRecorder.sharedInstance.stopRecording()
        XPAudioRecorder.sharedInstance.pushRemainingAudio()
    }
    
    //MARK: Helper methods
    private func uuidBytes() -> CFUUIDBytes {
        if UUIDBytesRef == nil {
            guard let audioId = audioId else { return CFUUIDBytes() }
            let uuid = CFUUIDCreateFromString(kCFAllocatorDefault, audioId as CFString)
            let bytes: CFUUIDBytes = CFUUIDGetUUIDBytes(uuid)
            
            // Reorder bytes int, short, short reversed
            UUIDBytesRef = CFUUIDCreateWithBytes(kCFAllocatorDefault, bytes.byte3, bytes.byte2, bytes.byte1, bytes.byte0, bytes.byte5, bytes.byte4, bytes.byte7, bytes.byte6, bytes.byte8, bytes.byte9, bytes.byte10, bytes.byte11, bytes.byte12, bytes.byte13, bytes.byte14, bytes.byte15)
        }
        
        return CFUUIDGetUUIDBytes(UUIDBytesRef)
    }
    
    private func createFrameData(audioData: Data) -> Data {
        var frameDataSize: Int = 0
        var audioIdBytes = uuidBytes()
        let audioIdData = Data(bytes: &audioIdBytes, count: MemoryLayout.size(ofValue: audioIdBytes))
        frameDataSize += audioIdData.count
        
        let millSecSinceJan1970: TimeInterval = Date().timeIntervalSince1970
        var timestamp = Int64(millSecSinceJan1970 * 1000)
        
        let timeStampData = Data(bytes: &timestamp, count: MemoryLayout.size(ofValue: timestamp))
        frameDataSize += timeStampData.count
        
        var frameCount: UInt32 = 0
        let frameCountData = Data(bytes: &frameCount, count: MemoryLayout.size(ofValue:frameCount))
        frameDataSize += frameCountData.count
        
        var frameSizeBytes = UInt32(audioData.count)
        let frameSizeBytesData = Data(bytes: &frameSizeBytes, count: MemoryLayout.size(ofValue:frameSizeBytes))
        frameDataSize += frameSizeBytesData.count
        
        var headerSizeBytes: UInt16 = 36
        let headerSizeBytesData = Data(bytes: &headerSizeBytes, count: MemoryLayout.size(ofValue:headerSizeBytes))
        frameDataSize += headerSizeBytesData.count
        
        var headerExtensionFlags: UInt16 = 0
        let headerExtensionFlagsData = Data(bytes: &headerExtensionFlags, count: MemoryLayout.size(ofValue:headerExtensionFlags))
        frameDataSize += headerExtensionFlagsData.count
        
        frameDataSize += audioData.count
        
        var frameData = Data(capacity: frameDataSize)
        frameData.append(audioIdData)
        frameData.append(timeStampData)
        frameData.append(frameCountData)
        frameData.append(frameSizeBytesData)
        frameData.append(headerSizeBytesData)
        frameData.append(headerExtensionFlagsData)
        frameData.append(audioData)
        
        return frameData
    }
    
    private func pushAudioFailed(error: NSError) {
        hasError = true
        let audioError: NSError
        if error.code != 0 || error.domain.count > 0 {
            audioError = XPAudioPushErrorHandler.sharedInstance.handleErrorCode(errorCode: error.code)
        } else {
            audioError = NSError(domain: Constants.ErrorHanler.audioPushErrorDomainName,
                                code: -11111,
                                userInfo: [NSLocalizedDescriptionKey: Constants.ErrorHanler.internalAudioPushError])
        }
        
        delegate?.didGetErrorWhilePushingAudio(error: audioError)
    }
    
    private func pushAudioSucceed(data: Data?, httpResponse: HTTPURLResponse) {
        if httpResponse.statusCode != 200 {
            let error = NSError(domain: Constants.ErrorHanler.audioPushErrorDomainName,
                                code: -11111,
                                userInfo: [NSLocalizedDescriptionKey: Constants.ErrorHanler.internalAudioPushError])
            hasError = true
            delegate?.didGetErrorWhilePushingAudio(error: error)
        } else if var data = data {
            if data.count < 36 { //there is no error header
                print("Uploaded audio data")
                if !XPAudioRecorder.sharedInstance.isRecording {
                    closeAudioPushStream()
                }
            } else {
                data.withUnsafeMutableBytes({ (rawMutableBufferPointer) -> Void in
                    let bufferPointer = rawMutableBufferPointer.bindMemory(to: Int8.self)
                    if let dataPtr = bufferPointer.baseAddress {
                        if let error = XPAudioPushErrorHandler.sharedInstance.handleError(dataPtr: dataPtr) {
                            hasError = true
                            delegate?.didGetErrorWhilePushingAudio(error: error)
                            closeAudioPushStream()
                            XPAudioRecorder.sharedInstance.stopRecording()
                        } else {
                            print("Uploaded audio data")
                            if !XPAudioRecorder.sharedInstance.isRecording {
                                closeAudioPushStream()
                            }
                        }
                    }
                })
            }
        }
    }
    
    private func closeAudioPushStream() {
        guard let audioId = audioId else { return }
        isStreamOpen = false
        XPMobileSDK.closeAudioStream(forAudioId: audioId,
                                     successHandler: {(response) in
            print("Closed stream") },
                                     failureHandler: nil)
    }

    private func audioPushFailed(error:NSError?) {
        guard let delegate = delegate else { return }
        
        currentRequest = nil
        XPAudioRecorder.sharedInstance.stopRecording()
        hasError = true

        guard let error = error else {
            let error = NSError(domain: Constants.ErrorHanler.audioPushErrorDomainName,
                                code: -11111,
                                userInfo: [NSLocalizedDescriptionKey: Constants.ErrorHanler.internalAudioPushError])
            delegate.didGetErrorWhilePushingAudio(error: error)
            print("Error requesting audio in stream")
            return
        }
        
        if error.code != 0 || error.domain.count > 0 {
            let error = XPAudioPushErrorHandler.sharedInstance.handleErrorCode(errorCode: error.code)
            delegate.didGetErrorWhilePushingAudio(error: error)
        } else {
            //if error code is 0 and domain is empty, then this is an error which we get when we cancelled the request
            //and we don't want to display that error
            print("Cancelled audio push request")
        }
    }
    
    private func audioPushSucceed(response: MIPSDKMobile.XPSDKResponse?) {
        currentRequest = nil
        
        guard let response = response,
              let url = XPSDKConnection.sharedConnection.url,
              let urlProtocol = url.scheme,
              let host = url.host,
              let port = url.port,
              let outputParameters = response.parameters,
              let audioId = outputParameters[Constants.Parameters.videoId] as? String,
              let streamId =  outputParameters[Constants.Parameters.streamId] as? String,
              let serviceAlias = XPSDKConnection.sharedConnection.serverInfo?.serviceAlias else { return }
        
        self.audioId = audioId
        self.streamId = streamId
        isStreamOpen = true
        let audioURL = String(format: Constants.RequestAudioParameters.urlStringFormat, serviceAlias, streamId)
        fullURL = String(format: Constants.RequestAudioParameters.urlFullStringFormat, urlProtocol, host, port, audioURL)
        print("Audio push started")
    }
}
