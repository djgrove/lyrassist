//
//  LAButton.swift
//  lyrAssist
//
//  Created by Austin McInnis on 2/22/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import UIKit

class LAButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    fileprivate func setupButton() {
        tintColor = .white
        backgroundColor = UIColor.lyrLightRed
        layer.cornerRadius = 3
        
        let insetValue = CGFloat(5.0)
        contentEdgeInsets = UIEdgeInsets(top: insetValue, left: insetValue, bottom: insetValue, right: insetValue)
    }
    
}
