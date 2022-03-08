//
//  Constants.swift
//  MobileSDKPTTSample
//
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import Foundation

struct Constants {
    static let allCamerasFolderId = "1926418B-893E-4AD6-A258-FB4A9AB57453"
    static let cameraListViewControllerTitle = "Cameras List"
    static let cameraListCellIdentifier = "cameraListCellIdentifier"
    static let pttListCellIdentifier = "pttListCellIdentifier"
    static let аlertOK = "OK"
    static let errorTitle = "Error"
    static let emptyString = ""
    static let storyboardName = "Main"
    
    struct Login {
        static let loginScreenTitle = "Mobile SDK Push to Talk Sample"
        static let loginDefaultPort = "8081"
        static let camerasSegueIdentifier = "goToCameras"
        static let loginErrorMessage = "Unable to login"
        static let loginConnectionErrorMessage = "Unable to connect"
        static let loginAboutTitle = "About"
        static let loginAboutMessage = "Milestone SDK Push to Talk Sample\nFor more information visit www.milestonesys.com."
    }
    
    struct Parameters {
        static let videoId = "VideoId"
        static let streamId = "StreamId"
    }
    
    struct ResponseItem {
        static let item = "Item"
        static let Id = "Id"
        static let name = "Name"
        static let type = "Type"
        static let properties = "Properties"
        static let items = "Items"
        static let camera = "Camera"
        static let folder = "Folder"
        static let view = "View"
        static let speaker = "Speaker"
        static let yes = "Yes"
    }
    
    struct Messages {
        static let permissionDeniedTitle = "Permission denied"
        static let permissionDeniedSubtitle = "The access to device microphone is denied. Go to settings to enable the permissions."
        static let pushToTalkErrorMessage = "Unable to start push to talk"
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
    
    struct ErrorHanler {
        static let internalAudioPushError = "Network error. Try later."
        static let audioPushErrorDomainName = "AudioPushError"
        static let audioPushErrorInsufficientRights = "InsufficientRights"
        static let audioPushErrorLostConnection = "The connection with the recording server is lost"
        static let audioPushErrorUnavailableFeature = "Feature is unavailable. Hardware device is disabled or in use"
        static let audioPushErrorDisabledFeature = "The push-to-talk feature has been disabled"
    }
}
