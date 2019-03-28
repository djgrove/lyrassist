//
//  lyrAssistNavController.swift
//  lyrAssist
//
//  Created by Austin McInnis on 2/14/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import FirebaseAuth
import UIKit

class lyrAssistNavController: UINavigationController {
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavBarStyle()
        
        // Authentication
        authHandle = Auth.auth().addStateDidChangeListener {
            [weak self] (auth, user) in
            guard let this = self else { return }
            
            if let user = user {
                if let name = user.displayName {
                    print("Currently logged in as \(name).")
                }
            }
            else {
                //Show welcome screen to login user
                this.performSegue(withIdentifier: "presentWelcome", sender: nil)
            }
        }
    }

    func setupNavBarStyle() {
        let navBar = self.navigationBar
        navBar.barTintColor = UIColor.LABurgundy
        navBar.tintColor = .white
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        if let authHandle = authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }
}
