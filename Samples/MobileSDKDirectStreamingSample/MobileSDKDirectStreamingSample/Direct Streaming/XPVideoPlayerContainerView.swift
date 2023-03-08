//
//  XPVideoPlayerContainerView.swift
//  XProtect
//
//  Created by BGMAC-PPE-01 on 8.11.19.
//  Copyright © 2019 Milestone Systems A/S. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class XPVideoPlayerContainerView : UIView {

    var playerLayer: AVPlayerLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @objc convenience init(frame: CGRect, playerLayer: AVPlayerLayer) {
        self.init(frame: frame)
        
        self.playerLayer = playerLayer
        layer.addSublayer(playerLayer)
    }
    
    @objc convenience init(frame: CGRect, player: AVPlayer, playerLayerFrame: CGRect) {
        self.init(frame: frame)
        
        setupPlayer(player, playerLayerFrame: playerLayerFrame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer?.frame = bounds
        CATransaction.commit()
    }
    
    @objc func setupPlayer(_ player: AVPlayer, playerLayerFrame: CGRect) {
        layer.sublayers?.removeAll()
        
        playerLayer = AVPlayerLayer(player: player)
        frame = playerLayerFrame
        playerLayer?.frame = playerLayerFrame
        backgroundColor = UIColor.clear
        
        if let playerLayer = playerLayer {
            layer.addSublayer(playerLayer)
        }
        
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
