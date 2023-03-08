//
//  PTTViewModel.swift
//  MobileSDKPTTSample
//
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import Foundation

class PTTViewModel: NSObject {
    let model: ResponseItem
    
    init(withModel model: ResponseItem) {
        self.model = model
    }
    
    var cameraName: String? {
        return model.name
    }
    
    var speakers: [SpeakerData]? {
        return model.items as? [SpeakerData]
    }
}
