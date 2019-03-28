//
//  WelcomeViewController.swift
//  lyrAssist
//
//  Created by Austin McInnis on 3/27/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import FirebaseAuth
import FirebaseUI
import UIKit

class WelcomeViewController: UIViewController, FUIAuthDelegate {

    private var authUI: FUIAuth?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.LABurgundy
        
        // Authentication
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        authUI?.providers = [FUIEmailAuth()]
    }
    
    @IBAction func login(_ sender: UIButton) {
        if let authUI = authUI {
            let authViewController = authUI.authViewController()
            present(authViewController, animated: true)
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let name = authDataResult?.user.displayName {
            print("\(name) successfully signed in.")
            dismiss(animated: true)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
