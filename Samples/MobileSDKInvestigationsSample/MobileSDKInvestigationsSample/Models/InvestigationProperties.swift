//
//  InvestigationProperties.swift
//  MobileSDKInvestigationsSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import Foundation

class InvestigationProperties: NSObject {
    @objc var startTime: NSNumber?
    @objc var endTime: NSNumber?
    @objc var createdAt: NSNumber?
    @objc var modifiedAt: NSNumber?
    @objc var createdBy: String?
    @objc var state: String?
    @objc var status: String?
    @objc var statusProgress: String?
    @objc var containsAudio: Bool = false
}
