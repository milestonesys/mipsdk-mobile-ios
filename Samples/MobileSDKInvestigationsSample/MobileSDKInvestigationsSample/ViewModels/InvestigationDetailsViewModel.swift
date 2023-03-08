//
//  InvestigationDetailsViewModel.swift
//  MobileSDKInvestigationsSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import Foundation

enum DateType: String {
    case start, end, lastModified
    
    func dateToShow() -> String {
        switch self {
            case .start:
                return Constants.Details.start
            case .end:
                return Constants.Details.end
            case .lastModified:
                return Constants.Details.lastModified
        }
    }
}

class InvestigationDetailsViewModel {
    let model: ResponseItem
    
    init(withModel model: ResponseItem) {
        self.model = model
    }
    
    var name: String {
        return model.name ?? ""
    }
    
    var state: String {
        return model.properties?.state ?? ""
    }
    
    var startTime: String {
        return dateForType(.start)
    }
    
    var endTime: String {
        return dateForType(.end)
    }
    
    var lastModified: String {
        return dateForType(.lastModified)
    }
    
    var createdBy: String {
        return Constants.Details.createdBy + " \(model.properties?.createdBy ?? "")"
    }
    
    var cameras: String {
        let count = model.items?.count ?? 0
        let cameraString = count == 1 ? Constants.Details.camera : Constants.Details.cameras
        return Constants.Details.contains + " \(count) \(cameraString):"
    }
    
    var camerasList: String {
        guard let items = model.items,
              !items.isEmpty else { return "" }
        
        var allCamerasString = ""
        for item in items {
            if item.type == Constants.Parameters.camera,
               let name = item.name,
               let identifier = item.identifier {
                allCamerasString = allCamerasString.appending("• \(name)\n")
                print("Found camera \"\(name)\" with ID \(identifier)")
            }
        }
        
        return allCamerasString
    }
}

//MARK: Helper methods
extension InvestigationDetailsViewModel {
    private func dateForType(_ type: DateType) -> String {
        var dateForType: NSNumber?
        
        switch type {
        case .start:
            dateForType = model.properties?.startTime
        case .end:
            dateForType = model.properties?.endTime
        case .lastModified:
            dateForType = model.properties?.modifiedAt
        }
        
        guard let dateToShow = dateForType else { return "" }
        let date = String.dateFromTimestamp(dateToShow)
        let time = String.timeFromTimestamp(dateToShow)
        
        return type.dateToShow() + " \(date) \(time)"
    }
}
