//
//  ArtistBioViewController.swift
//  lyrAssist
//
//  Created by Austin McInnis on 2/14/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import SafariServices
import UIKit

class ArtistBioViewController: UIViewController {

    @IBOutlet var artistBioTextView: UITextView!
    @IBOutlet var artistImageView: UIImageView!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var lastFMButton: LAButton!
    
    var artist: Artist?
    var lastFMUrl: URL? {
        didSet {
            guard lastFMUrl != nil else {
                lastFMButton.isHidden = true
                print("lastFMUrl set to nil.")
                return
            }
            
            lastFMButton.isHidden = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.barTintColor = UIColor.lyrLightRed
        
        if let artist = artist {
            artistNameLabel.text = artist.name
            if let image = artist.avatarImage {
                artistImageView.image = image
            }
            if let bio = artist.bio {
                setupBio(bio: bio)
            }
        }
    }
    
    fileprivate func setupBio(bio unescapedBio: String) {
        
        //Extract HTML link out of bio, present in button format
        let bioData = Data(unescapedBio.utf8)
        if let attributedString = try? NSAttributedString(data: bioData, options: [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil) {
            
            attributedString.enumerateAttribute(.link, in: NSMakeRange(0, attributedString.length), options: [.longestEffectiveRangeNotRequired]) {
                [weak self] (link, range, isStop) in
                guard let this = self else { return }
                
                if let link = link {
                    //Update url to trigger button in UI
                    let urlStr = String(describing: link)
                    this.lastFMUrl = URL(string: urlStr)
                    let linkIndex = unescapedBio.index(unescapedBio.startIndex, offsetBy: range.location)
                    DispatchQueue.main.async {
                        this.artistBioTextView.text = String(unescapedBio[unescapedBio.startIndex..<linkIndex])
                        this.resize(textView: this.artistBioTextView)
                    }
                }
            }
        }
    }
    
    @IBAction func readMoreOnLastFM(_ sender: UIButton) {
        if let url = lastFMUrl {
            let lastFMWebVC = SFSafariViewController(url: url)
            present(lastFMWebVC, animated: true, completion: nil)
        }
    }
    
    fileprivate func resize(textView: UITextView) {
        var newFrame = textView.frame
        let width = newFrame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        newFrame.size = CGSize(width: width, height: newSize.height)
        textView.frame = newFrame
    }
    
    // MARK: - Navigation
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
