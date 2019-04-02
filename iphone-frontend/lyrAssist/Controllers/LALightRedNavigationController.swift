//
//  LALightRedNavigationController.swift
//  lyrAssist
//
//  Created by Austin McInnis on 3/28/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import UIKit

class LALightRedNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barTintColor = UIColor.LALightRed
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
