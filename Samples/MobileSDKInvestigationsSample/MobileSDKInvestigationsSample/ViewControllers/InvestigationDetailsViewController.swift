//
//  InvestigationDetailsViewController.swift
//  MobileSDKInvestigationsSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import UIKit

class InvestigationDetailsViewController: UIViewController {
    var investigationDetails: ResponseItem?
    var containerView: InvestigationDetailsView?
        
    // MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let investigationDetails = investigationDetails else { return }
        
        containerView = InvestigationDetailsView(withModel: investigationDetails,
                                                 andFrame: view.bounds)
        if let containerView = containerView {
            view.addSubview(containerView)
        }
    }
}
