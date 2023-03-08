//
//  MicrophoneData.swift
//  MobileSDKAudioSample
//
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import Foundation

class MicrophoneData: ResponseItem {
    var supportsAudio: Bool {
        return identifier != nil
    }
    
    var supportsLiveAudio: Bool {
        guard let properties = properties as? MicrophoneProperties,
              let audioLive = properties.live else { return false }
        return supportsAudio && audioLive == Constants.ResponseItem.supportsLiveAudioYesOption
    }
}
