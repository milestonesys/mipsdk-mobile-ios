//
//  AudioPushButton.swift
//  MobileSDKPTTSample
//
//  Copyright © 2018 Milestone Systems A/S. All rights reserved.
//

import UIKit

class AudioPushButton: UIButton {
    let btnRadius: CGFloat = 40.0
    var normalStateFrame: CGRect = .zero
    
    override var isHighlighted: Bool {
        willSet { adjustButtonColor(isButtonHighlighted: newValue) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func adjustButtonColor(isButtonHighlighted: Bool) {
        if normalStateFrame.equalTo(.zero) {
            normalStateFrame = layer.frame
        }
        
        if isButtonHighlighted {
            if layer.frame.size.width == normalStateFrame.size.width {
                let btnBackgroundColor = UIColor(red: 0.0,
                                                 green: 153.0/255.0,
                                                 blue: 218.0/255.0,
                                                 alpha: 0.8)
                layer.backgroundColor = btnBackgroundColor.cgColor
                layer.borderColor = btnBackgroundColor.cgColor
                layer.borderWidth = 1.0
                layer.masksToBounds = true
                layer.cornerRadius = normalStateFrame.size.height / 2.0
                
                let width = normalStateFrame.size.width + btnRadius * 2.0
                let x = normalStateFrame.origin.x - btnRadius
                let y = normalStateFrame.origin.y - (width - normalStateFrame.size.height)/2.0
                
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.transform = .identity
                    self?.layer.frame = CGRect(x: x, y: y, width: width, height: width)
                    self?.layer.cornerRadius = width / 2.0
                }, completion: nil)
            }
        } else {
            layer.frame = normalStateFrame
            normalStateFrame = .zero
            layer.masksToBounds = false
            layer.cornerRadius = 0.0
            layer.backgroundColor = UIColor.clear.cgColor
            layer.borderColor = UIColor.clear.cgColor
        }
    }
}
