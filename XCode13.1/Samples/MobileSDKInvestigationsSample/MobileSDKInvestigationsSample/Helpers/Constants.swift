//
//  Constants.swift
//  MobileSDKInvestigationsSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import Foundation
import MIPSDKMobile

struct Constants {
    static let allInvestigationsID = "A3B9C5FB-FAAD-42C8-AB73-B79D6FFFDBC1"
    static let listViewControllerTitle = "Investigations List"
    static let listViewControllerBackButtonTitle = "Back"
    static let tableviewCellIdentifier = "cellIdentifier"
    static let emptyString = ""
    static let storyboardName = "Main"
    
    struct Login {
        static let loginScreenTitle = "Mobile SDK Investigations Sample"
        static let loginDefaultPort = "8081"
        static let camerasSegueIdentifier = "goToCameras"
        static let loginErrorTitle = "Error"
        static let loginErrorMessage = "Unable to login"
        static let loginConnectionErrorMessage = "Unable to connect"
        static let loginAboutTitle = "About"
        static let loginAboutMessage = "Milestone SDK Investigations Sample\nFor more information visit www.milestonesys.com."
        static let loginAlertOK = "OK"
    }
    
    struct Details {
        static let start = "Start:"
        static let end = "End:"
        static let lastModified = "Last modified on:"
        static let createdBy = "Created by:"
        static let contains = "Contains"
        static let camera = "camera"
        static let cameras = "cameras"
    }
    
    struct Parameters {
        static let getInvestigation = "GetInvestigation"
        static let itemId = "ItemId"
        static let investigation = "Investigation"
        static let camera = "Camera"
    }
    
    struct ResponseItem {
        static let item = "Item"
        static let Id = "Id"
        static let name = "Name"
        static let type = "Type"
        static let properties = "Properties"
        static let items = "Items"
    }
}
