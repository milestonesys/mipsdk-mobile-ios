//
//  InvestigationDetailsView.swift
//  MobileSDKInvestigationsSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import UIKit

class InvestigationDetailsView: UIView {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lastModified: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var createdBy: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var cameras: UILabel!
    @IBOutlet weak var camerasList: UITextView!
    
    var viewModel: InvestigationDetailsViewModel
    
    init(withModel model: ResponseItem, andFrame frame: CGRect) {
        viewModel = InvestigationDetailsViewModel(withModel: model)
        
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Helper methods
extension InvestigationDetailsView {
    private func updateData() {
        name.text = viewModel.name
        lastModified.text = viewModel.lastModified
        state.text = viewModel.state
        createdBy.text = viewModel.createdBy
        startTime.text = viewModel.startTime
        endTime.text = viewModel.endTime
        cameras.text = viewModel.cameras
        camerasList.text = viewModel.camerasList
    }
    
    private func setup() {
        view = loadedViewFromNib()
        view.frame = bounds
        addSubview(view)
        
        updateData()
    }
}
