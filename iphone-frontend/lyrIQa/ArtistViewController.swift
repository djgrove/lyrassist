//
//  ArtistViewController.swift
//  lyrIQa
//
//  Created by Austin McInnis on 1/27/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import UIKit

protocol ArtistDelegate {
    func updateArtist(id: Int, withSong: String)
}

class ArtistViewController: UIViewController {

    
    @IBOutlet var songTextView: UITextView!
    var artist:Artist?
    var artistDelegate: ArtistDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let artist = artist {
            self.navigationItem.title = artist.name
            if let song = artist.song {
                self.songTextView.text = song
            }
            else {
                //Query, use delegation to store song in artist object
                // TODO: Setup delegation to store song in cache
                if let urlStr = artist.url, let url = URL(string: urlStr) {
                    let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                        guard let this = self else { return }
                        DispatchQueue.main.async {
                            if let data = data{
                                do {
                                let json = try JSONSerialization.jsonObject(with: data, options: [])
                                    if let jsonData = json as? [String:Any] {
                                        if let song = jsonData["data"] as? String {
                                            this.songTextView.text = song
                                            this.artistDelegate?.updateArtist(id: artist.id!, withSong: song)
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
                    }
                    
                    task.resume()
                }
                else {
                    fatalError("Received invalid url for artist: \(artist.name)")
                }
            }
        }
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
