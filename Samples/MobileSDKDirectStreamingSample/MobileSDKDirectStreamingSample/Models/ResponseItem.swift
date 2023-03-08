//
//  ResponseItem.swift
//  MobileSDKDirectStreamingSample
//
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import Foundation

class ResponseItem: NSObject {
    var identifier: String?
    var name: String?
    var type: String?
    var items: [ResponseItem]?
    
    required override init() {
        super.init()
    }
}
