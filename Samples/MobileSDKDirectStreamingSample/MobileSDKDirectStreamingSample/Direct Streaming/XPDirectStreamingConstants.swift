//
//  XPDirectStreamingConstants.swift
//  XProtect
//
//  Created by BGMAC-PPE-01 on 4.02.20.
//  Copyright © 2020 Milestone Systems A/S. All rights reserved.
//

import Foundation

struct XPDirectStreamingConstants {
    
    enum VideoCodec: String {
        case h264 = "H264"
        case h265 = "H265"
    }
    
    static let fileExtension = ".mp4"
    static let baseFileName = "DSvideo"
    
    static let kPlayerStatusKey = "status"
    static let playerTimeControlStatusKey = "timeControlStatus"
    static let defaultVideosFolderName = "directStreaming"
    
    static let intervalForGatheringGapMetrics = 4.2
    static let maxAccumulatedGapTime = 4.0
    static let maxNumberOfGaps = 4

}
