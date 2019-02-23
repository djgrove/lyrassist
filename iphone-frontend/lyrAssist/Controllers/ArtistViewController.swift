//
//  ArtistViewController.swift
//  lyrAssist
//
//  Created by Austin McInnis on 1/27/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import UIKit

protocol ArtistDelegate {
    func updateArtistInfo(id: String, withSong: String?, withBio: String?)
    func updateArtistImage(id: String, withImage: UIImage)
}

class ArtistViewController: UIViewController {

    @IBOutlet var songTextView: UITextView!
    
    var artist:Artist?
    var artistDelegate: ArtistDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupInfoButton()
        
        if let artist = artist {
            self.navigationItem.title = artist.name
            
            // Artist Image
            if artist.avatarImage != nil {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            else if let avatarURLStr = artist.avatarURL, let avatarURL = URL(string: avatarURLStr) {
                downloadArtistImage(url: avatarURL)
            }
            
            //Artist Lyrics
            if let song = artist.song {
                self.songTextView.text = song
            }
            else {
                if let urlStr = artist.url, let url = URL(string: urlStr) {
                    downloadArtist(url: url)
                }
                else {
                    fatalError("Received invalid url for artist: \(artist.name)")
                }
            }
        }
        
    }
    
    // MARK: - Network Functions
    func downloadArtistImage(url: URL) {
        let avatarTask = URLSession.shared.dataTask(with: url) {
            [weak self] data, response, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let this = self else { return }
            if let data = data, let image = UIImage(data: data) {
                //Update Data Model
                this.artist?.avatarImage = image
                this.artistDelegate?.updateArtistImage(id: this.artist!.id, withImage: image)
                
                //Update Nav Bar UI for info button
                DispatchQueue.main.async {
                    this.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            }
        }
        avatarTask.resume()
    }
    
    func downloadArtist(url: URL) {
        let songTask = URLSession.shared.dataTask(with: url) {
            [weak self] data, response, error in
            guard let this = self else { return }
            if let data = data{
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let jsonData = json as? [String:Any] {
                        //Lyrics
                        let song = jsonData["lyrics"] as? String
                        if let song = song {
                            DispatchQueue.main.async {
                                this.songTextView.text = song
                            }
                        }
                        else {
                            throw LAError.ParseError(subject: "lyrics", artist: this.artist!.name)
                        }
                        
                        //Bio
                        let bio = jsonData["bio"] as? String
                        if let bio = bio {
                            this.artist!.bio = bio
                        }
                        else {
                            throw LAError.ParseError(subject: "bio", artist: this.artist!.name)
                        }
                        
                        //Update
                        this.artistDelegate?.updateArtistInfo(id: this.artist!.id, withSong: song, withBio: bio)
                    }
                }
                catch LAError.ParseError(let subject, let artist) {
                    print("Parsing Error: Could not parse \(subject) for \(artist)")
                }
                catch let jsonError {
                    fatalError(jsonError.localizedDescription)
                }
            }
            else {
                this.songTextView.text = error?.localizedDescription
            }
        }
        songTask.resume()
    }
    
    // MARK: - Navigation Bar Config
    func setupInfoButton() {
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        barButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func infoButtonTapped() {
        performSegue(withIdentifier: "BioSegue", sender: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? lyrAssistNavController {
            if let bioViewController = navVC.topViewController as? ArtistBioViewController {
                bioViewController.artist = artist                
            }
        }
    }
}
