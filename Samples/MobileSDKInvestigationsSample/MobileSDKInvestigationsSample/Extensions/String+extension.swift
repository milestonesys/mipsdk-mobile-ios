//
//  String+extension.swift
//  MobileSDKInvestigationsSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import Foundation

extension String {
    static func dateFromTimestamp(_ timestamp: NSNumber) -> String {
        let date = Date(timeIntervalSince1970: Double(Double(truncating: timestamp)) / 1000.0)
        return DateFormatter.localizedString(from: date,
                                             dateStyle: .medium,
                                             timeStyle: .none)
    }
    
    static func timeFromTimestamp(_ timestamp: NSNumber) -> String {
        let date = Date(timeIntervalSince1970: Double(Double(truncating: timestamp)) / 1000.0)
        return DateFormatter.localizedString(from: date,
                                             dateStyle: .none,
                                             timeStyle: .medium)
    }
}
