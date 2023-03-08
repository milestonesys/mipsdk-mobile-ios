//
//  Constants.swift
//  MobileSDKLiveSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    //MARK: CamerasListViewController
    static let camerasListScreenTitle = "Cameras List"
    static let storyboardName = "Main"
    static let allCamerasFolderId = "1926418B-893E-4AD6-A258-FB4A9AB57453"
    static let tableViewCellIdentifier = "CameraTableItem"
    
    //MARK: CameraLiveViewController
    static let videoConnectionClosingMessage = "Video connection closed"
    
    //MARK: CameraVideoView
    static let videoConnectionReceivedResponse = "Camera video view received connection response"
    static let imageSizeLog = "image size:"
    static let newSizeReceivedLog = "Camera video view received NEW size:"
    static let loadingIndicatorFrame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
    
    static let alertOK = "OK"
    static let emptyString = ""
    
    struct Login {
        static let loginScreenTitle = "Mobile SDK Live Video Sample"
        static let loginDefaultPort = "8081"
        static let loginDefaultSecurePort = "8082"
        static let camerasSegueIdentifier = "goToCameras"
        static let loginErrorTitle = "Error"
        static let loginErrorMessage = "Unable to login"
        static let loginConnectionErrorMessage = "Unable to connect"
        static let loginAboutTitle = "About"
        static let loginAboutMessage = "Milestone SDK Live Video Sample\nFor more information visit www.milestonesys.com."
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
    }
    
    struct ErrorHandler {
        static let connectionLostMessage = "Connection lost"
        static let videoConnectionClosingErrorMessage = "Error closing video connection"
    }
    
    struct RequestStreamParameters {
        static let size = CGSize(width: 1920, height: 1440)
        static let fps = 8
        static let compressionLevel = 90
        static let upstreamVideoQuality: Float = 0.0
        static let closeConnectionOnError = "No"
    }
}
