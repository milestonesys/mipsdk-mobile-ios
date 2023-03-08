//
//  SpeakerData.swift
//  MobileSDKPTTSample
//
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import Foundation

class SpeakerData: ResponseItem {
    var supportsAudioPush: Bool {
        return identifier != nil
    }
    
    var supportsAudioPushSpeak: Bool {
        guard let properties = properties as? SpeakerProperties,
              let speak = properties.speak else { return false }
        
        return supportsAudioPush && speak == Constants.ResponseItem.yes
    }
}
