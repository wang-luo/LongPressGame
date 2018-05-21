//
//  TilesView.swift
//  longPressTileProject
//
//  Created by wang on 2018/05/21.
//  Copyright © 2018年 json. All rights reserved.
//

import Foundation
import UIKit

class GameTile: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class GameTileLong: GameTile {
    
    var frameDefault: CGRect
    let isHiddenDefault: Bool
    let isUserInteractionEnabledDefault: Bool
    let colorName: UIColor
    var tileLane: Int
    
    /// initializer
    init(
        frame: CGRect,
        isHidden: Bool = false,
        isUserInteractionEnabled: Bool = true,
        color: UIColor = UIColor.yellow,
        lane: Int) {
        frameDefault = frame
        isHiddenDefault = isHidden
        isUserInteractionEnabledDefault = isUserInteractionEnabled
        colorName = color
        tileLane = lane
        
        super.init(frame: frame)
        super.isHidden = isHiddenDefault
        super.isUserInteractionEnabled = isUserInteractionEnabledDefault
        super.backgroundColor = colorName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

