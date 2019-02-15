//
//  ArtistBioViewController.swift
//  lyrIQa
//
//  Created by Austin McInnis on 2/14/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import UIKit

class ArtistBioViewController: UIViewController {

    @IBOutlet var artistBioTextView: UITextView!
    @IBOutlet var artistImageView: UIImageView!
    @IBOutlet var artistNameLabel: UILabel!
    
    var artist: Artist?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barTintColor = UIColor.lyrLightRed
        
        if let artist = artist {
            if let image = artist.avatarImage {
                artistImageView.image = image
            }
            artistNameLabel.text = artist.name
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
