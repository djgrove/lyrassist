//
//  ArtistViewController.swift
//  lyrIQa
//
//  Created by Austin McInnis on 1/27/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import UIKit

protocol ArtistDelegate {
    func updateArtistSong(id: Int, withSong: String)
    func updateArtistImage(id: Int, withImage: UIImage)
}

class ArtistViewController: UIViewController {

    @IBOutlet var songTextView: UITextView!
    
    var artist:Artist?
    var artistDelegate: ArtistDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //Setup info button
        setupInfoButton()
        if let artist = artist {
            self.navigationItem.title = artist.name
            if artist.avatarImage != nil {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            else if let avatarURLStr = artist.avatarURL, let avatarURL = URL(string: avatarURLStr) {
                let avatarTask = URLSession.shared.dataTask(with: avatarURL) {
                    [weak self] data, response, error in
                    guard error == nil else {
                        print(error!.localizedDescription)
                        return
                    }
                    guard let this = self else { return }
                    if let data = data, let image = UIImage(data: data) {
                        //Update Data Model
                        this.artist?.avatarImage = image
                        this.artistDelegate?.updateArtistImage(id: artist.id!, withImage: image)
                        
                        //Update Nav Bar UI for info button
                        DispatchQueue.main.async {
                            this.navigationItem.rightBarButtonItem?.isEnabled = true
                        }
                    }
                }
                avatarTask.resume()
            }
            
            if let song = artist.song {
                self.songTextView.text = song
            }
            else {
                //Query, use delegation to store song in artist object
                // TODO: Setup delegation to store song in cache
                if let urlStr = artist.url, let url = URL(string: urlStr) {
                    let songTask = URLSession.shared.dataTask(with: url) {
                        [weak self] data, response, error in
                        guard let this = self else { return }
                        if let data = data{
                            do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                                if let jsonData = json as? [String:Any] {
                                    if let song = jsonData["data"] as? String {
                                        DispatchQueue.main.async {
                                            this.songTextView.text = song
                                        }
                                        this.artistDelegate?.updateArtistSong(id: artist.id!, withSong: song)
                                    }
                                    else {
//                                        preconditionFailure("Could not get song from json for \(artist.name)")
                                    }
                                }
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
                else {
                    fatalError("Received invalid url for artist: \(artist.name)")
                }
            }
        }
        
    }
    
    func setupInfoButton() {
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        barButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func infoButtonTapped() {
        print("Info button tapped")
    }
}
