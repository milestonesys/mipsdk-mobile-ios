//
//  XPAudioPushErrorHandler.swift
//  MobileSDKPTTSample
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import Foundation
import MIPSDKMobile

class XPAudioPushErrorHandler: NSObject {
    let mainHeaderSize = 36
    let headerSizeBytesHasExtension = 0
    let headerSizeBytesOffset = 32
    let headerExtensionFlagsOffset = 34
    let mainHeaderExtensionSize = 4
    let headerExtensionDynamicInfo = 0x0100
    let dataCountOffset = 8
    let dataTypeOffset = 12
    let errorCodeOffset = 32
    
    enum XPAudioPushError: Int {
        case surveillanceServerDown = 17
        case itemNotPlayable = 54
        case insufficientUserRights = 25
        case disabledFeature = 24
        case internalError = -2
    }
    
    static let sharedInstance = XPAudioPushErrorHandler()
    
    func handleError(dataPtr: UnsafeMutablePointer<Int8>) -> NSError? {
        var headerSizeBytes = Int32(get_int16(dataPtr + headerSizeBytesOffset))
        var headerOffset = mainHeaderSize
        if headerSizeBytes == headerSizeBytesHasExtension {
            headerSizeBytes = get_int32(dataPtr + mainHeaderSize)
            headerOffset += mainHeaderExtensionSize
        }
        
        if headerSizeBytes <= headerOffset {
            return nil
        }
        
        let headerExtensionFlags = get_int16(dataPtr + headerExtensionFlagsOffset)
        if headerExtensionFlags == headerExtensionDynamicInfo {
            let dataCount = get_int32(dataPtr + headerOffset + dataCountOffset)
            let dataType = get_int32(dataPtr + headerOffset + dataTypeOffset)
            
            if dataCount != 0 && dataType == 0 {
                let errorCode = Int(get_int32(dataPtr + headerOffset + errorCodeOffset))
                return handleErrorCode(errorCode: errorCode)
            }
        }
        
        return nil
    }
    
    func handleErrorCode(errorCode:Int) -> NSError {
        guard let audioPushError = XPAudioPushError(rawValue: errorCode) else {
            return NSError(domain: Constants.ErrorHanler.audioPushErrorDomainName,
                           code: errorCode,
                           userInfo: [NSLocalizedDescriptionKey: Constants.ErrorHanler.internalAudioPushError])
        }
        
        let errorDescription: String
        
        switch (audioPushError) {
            case XPAudioPushError.insufficientUserRights:
                errorDescription = Constants.ErrorHanler.audioPushErrorInsufficientRights
            case XPAudioPushError.surveillanceServerDown:
                errorDescription = Constants.ErrorHanler.audioPushErrorLostConnection
            case XPAudioPushError.itemNotPlayable:
                errorDescription = Constants.ErrorHanler.audioPushErrorUnavailableFeature
            case XPAudioPushError.disabledFeature:
                errorDescription = Constants.ErrorHanler.audioPushErrorDisabledFeature
            case XPAudioPushError.internalError:
                errorDescription = Constants.ErrorHanler.internalAudioPushError
        }
        
        return NSError(domain: Constants.ErrorHanler.audioPushErrorDomainName,
                       code: errorCode,
                       userInfo: [NSLocalizedDescriptionKey: errorDescription])
    }
}
