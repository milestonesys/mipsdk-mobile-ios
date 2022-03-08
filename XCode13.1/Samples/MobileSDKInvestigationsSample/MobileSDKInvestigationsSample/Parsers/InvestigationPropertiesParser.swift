//
//  InvestigationPropertiesParser.swift
//  MobileSDKInvestigationsSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import Foundation

struct Properties {
    let startTime = "StartTime"
    let endTime = "EndTime"
    let createdAt = "CreatedAt"
    let createdBy = "CreatedBy"
    let modifiedAt = "ModifiedAt"
    let state = "State"
    let status = "Status"
    let statusProgress = "StatusProgress"
    let containsAudio = "ContainsAudio"
}

class InvestigationPropertiesParser {
    var dataParsed = false
    
    func parseData(_ data: Item) -> Result<InvestigationProperties, Error> {
        let properties = InvestigationProperties()
        
        let keys = Properties()
        let mirror = Mirror(reflecting: keys)
        
        for child in mirror.children  {
            if let propertyValue = child.value as? String,
               let propertyKey = child.label,
               let value = data[propertyValue] {
                dataParsed = true
                properties.setValue(value, forKey: propertyKey)
            }
        }
        
        if dataParsed {
            return .success(properties)
        } else {
            return .failure(NSError())
        }
    }
}
