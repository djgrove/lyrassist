//
//  lyrAssistNavController.swift
//  lyrIQa
//
//  Created by Austin McInnis on 2/14/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import UIKit

class lyrAssistNavController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavBarStyle()
    }

    func setupNavBarStyle() {
        let navBar = self.navigationBar
        navBar.barTintColor = UIColor.lyrBurgundy
        navBar.tintColor = .white
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
