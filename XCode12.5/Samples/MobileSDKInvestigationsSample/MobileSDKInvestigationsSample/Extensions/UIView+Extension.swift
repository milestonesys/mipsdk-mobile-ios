//
//  UIView+Extension.swift
//  MobileSDKInvestigationsSample
//
//  Copyright © 2021 Milestone. All rights reserved.
//

import UIKit

extension UIView {
    func loadedViewFromNib() -> UIView! {
        let bundle = Bundle.main
        let nib = UINib(nibName: String(describing: Self.self), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
          
        return view
    }
}
