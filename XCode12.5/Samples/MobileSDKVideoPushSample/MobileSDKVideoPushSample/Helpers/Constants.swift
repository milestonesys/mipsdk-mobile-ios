//
//  Constants.swift
//  MobileSDKVideoPushSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let emptyString = ""
    
    //MARK: CameraViewController
    static let startStreamAlertOK = "OK"
    static let startStreamAlertTitle = "An error occured while trying to push video"
    static let startStreamParamCloseConnectionOnError = "Yes"
    static let startStreamBufferQueue = "bufferQueue"
    
    struct Login {
        static let loginScreenTitle = "Mobile SDK Video Push Sample"
        static let loginDefaultPort = "8081"
        static let cameraSegueIdentifier = "goToCamera"
        static let loginErrorTitle = "Error"
        static let loginErrorMessage = "Unable to login"
        static let loginConnectionErrorMessage = "Unable to connect"
        static let loginAboutTitle = "About"
        static let loginAboutMessage = "Milestone SDK Video Push Sample\nFor more information visit www.milestonesys.com."
        static let loginAlertOK = "OK"
    }
    
    struct ErrorHanler {
        static let internalAudioPushError = "Network error. Try later."
        static let audioPushErrorDomainName = "AudioPushError"
        static let audioPushErrorInsufficientRights = "InsufficientRights"
        static let audioPushErrorLostConnection = "The connection with the recording server is lost"
        static let audioPushErrorUnavailableFeature = "Feature is unavailable. Hardware device is disabled or in use"
        static let audioPushErrorDisabledFeature = "The push-to-talk feature has been disabled"
    }
    
    struct Parameters {
        static let videoId = "VideoId"
        static let streamId = "StreamId"
    }
    
    struct RequestAudioParameters {
        static let httpMethod = "POST"
        static let urlStringFormat = "/%@/Audio/%@"
        static let urlFullStringFormat = "%@://%@:%u%@"
        static let audioEncoding = "Pcm"
        static let samplingRate = "8000"
        static let bitsPerSample = "16"
        static let numberOfChannels = "1"
        static let closeConnectionOnError = "Yes"
    }
}
