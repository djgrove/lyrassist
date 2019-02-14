//
//  lyrAssistNavController.swift
//  lyrIQa
//
//  Created by Austin McInnis on 2/14/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import UIKit

class lyrAssistNavController: UINavigationController {

    let burgundy = UIColor(red: 127.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavBarStyle()
    }

    func setupNavBarStyle() {
        let navBar = self.navigationBar
        navBar.barTintColor = burgundy
        navBar.tintColor = .white
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
