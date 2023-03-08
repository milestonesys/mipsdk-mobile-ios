//
//  ResponseItem.swift
//  MobileSDKInvestigationsSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import Foundation

class ResponseItem: NSObject {
    var identifier: String?
    var name: String?
    var type: String?
    var properties: InvestigationProperties?
    var items: [ResponseItem]?
}
