//
//  SpeakerPropertiesParser.swift
//  MobileSDKPTTSample
//
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import Foundation

struct Properties {
    let exportDatabase = "ExportDatabase"
    let playback = "Playback"
    let live = "Live"
    let speak = "Speak"
    let sequences = "Sequences"
}

class SpeakerPropertiesParser {
    var dataParsed = false
    
    func parseData(_ data: Item) -> Result<Any, Error> {
        let properties = SpeakerProperties()
        
        let keys = Properties()
        let mirror = Mirror(reflecting: keys)
        
        for child in mirror.children  {
            if let propertyValue = child.value as? String,
               let propertyKey = child.label, let value = data[propertyValue] {
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
