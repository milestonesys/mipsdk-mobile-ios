//
//  Constants.swift
//  MobileSDKAudioSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import Foundation

struct Constants {
    
    //MARK: CamerasListViewController
    static let camerasListScreenTitle = "Cameras List"
    static let storyboardName = "Main"
    static let allCamerasFolderId = "1926418B-893E-4AD6-A258-FB4A9AB57453"
    static let tableViewCellIdentifier = "CameraTableItem"
    
    //MARK: Audio
    static let audioTimeControlStatus = "timeControlStatus"
    static let emptyString = ""
    static let audioEncoding = "Mp3"
    static let audioMethodType = "Push"
    static let audioOnImage = "AudioOn"
    static let audioOffImage = "AudioOff"
    static let audioVCTableViewCellIdentifier = "MicrophoneTableItem"
    static let audioSignalType = "Live"
    static let audioUrl = "/%@/Audio/%@"
    static let fullUrl = "%@://%@:%u%@"
    
    struct Login {
        static let loginScreenTitle = "Mobile SDK Audio Sample"
        static let loginDefaultPort = "8081"
        static let camerasSegueIdentifier = "goToCameras"
        static let loginErrorTitle = "Error"
        static let loginErrorMessage = "Unable to login"
        static let loginConnectionErrorMessage = "Unable to connect"
        static let loginAboutTitle = "About"
        static let loginAboutMessage = "Milestone SDK Audio Sample\nFor more information visit www.milestonesys.com."
    }
    
    struct ResponseItem {
        static let cameraName = "Name"
        static let cameraId = "Id"
        static let items = "Items"
        static let item = "Item"
        static let type = "Type"
        static let camera = "Camera"
        static let folder = "Folder"
        static let view = "View"
        static let microphoneId = "Id"
        static let videoId = "VideoId"
        static let properties = "Properties"
        static let microphone = "Microphone"
        static let supportsLiveAudioYesOption = "Yes"
    }
    
    struct ErrorHandler {
        static let audioError = -11111
        static let audioErorTitle = "Error"
        static let alertOK = "OK"
        static let networkErrorMessage = "Network error. Try later."
        static let noAudioConnectionErrorMessage = "No audio connection. Try later."
        static let noUserRightsErrorMessage = "No user rights."
        static let audioErrorMessage = "AudioError"
    }
}
