//
//  ArtistsTableViewController.swift
//  lyrAssist
//
//  Created by Austin McInnis on 1/27/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import UIKit

class ArtistCell: UITableViewCell {
    var artist: Artist?
}

class ArtistsTableViewController: UITableViewController, ArtistDelegate {

    var artists = [Artist]()
    var components = URLComponents()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        
        getArtists()
    }
    
    // MARK: - Network Functions
    func getArtists() {
        components.scheme = "https"
        components.host = "ffpy6gqw9j.execute-api.us-west-1.amazonaws.com"
        components.path = "/prod/list"
        
        guard let url = components.url else {
            preconditionFailure("Failed to construct URL")
        }
        
        let task = URLSession.shared.dataTask(with: url) {
            [weak self] data, response, error in
            guard let this = self else { return }
            
            if let data = data {
//                print(String(decoding: data, as: UTF8.self))
                do {
                    let decoder = JSONDecoder()
                    let artistResponse = try decoder.decode(ArtistListResponse.self, from: data)
                    var artistComponents = URLComponents(url: this.components.url!, resolvingAgainstBaseURL: false)
                    artistComponents?.path = "/prod/generate"
                    for jsonArtist in artistResponse.data {
                        artistComponents?.queryItems = [URLQueryItem(name: "artist", value: jsonArtist.id)]
                        guard let artistURL = artistComponents?.url else {
                            preconditionFailure("Failed to construct artistURL for \(jsonArtist.name)")
                        }
                        let artist = Artist(id: jsonArtist.id,
                                            name: jsonArtist.name,
                                            url: artistURL.absoluteString,
                                            avatarURL: jsonArtist.avatarURL,
                                            avatarImage: nil,
                                            song: nil,
                                            bio: nil)
                        this.artists.append(artist)
                    }
//                    print(this.artists)
                    this.artists = this.artists.sorted(by: { $0.name < $1.name })
                    DispatchQueue.main.async {
                        this.tableView.reloadData()
                    }
                }
                catch let jsonError {
                    fatalError(jsonError.localizedDescription)
                }
            }
        }
        
        task.resume()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.artists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell") as? ArtistCell else {
            fatalError("The dequeued cell is not an instance of ArtistCell")
        }
        
        let artist = self.artists[indexPath.row]
        cell.artist = artist
        cell.textLabel?.text = artist.name
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ArtistSelected" {
            if let artistVC = segue.destination as? ArtistViewController {
                if let cell = sender as? ArtistCell {
                    if let artistId = cell.artist?.id {
                        let index = self.artists.firstIndex(where: { $0.id == artistId })
                        artistVC.artist = self.artists[index!]
                        artistVC.artistDelegate = self
                    }
                }
            }
        }
    }
    
    // MARK: Artist Delegate
    
    func updateArtistInfo(id: String, withSong song: String?, withBio bio: String?) {
        if let index = self.artists.firstIndex(where: { $0.id == id }) {
            if let song = song {
                self.artists[index].song = song
            }
            if let bio = bio {
                self.artists[index].bio = bio
            }
        }
        else {
            print("Artist lookup failed in updateArtistSong.")
        }
    }
    
    func updateArtistImage(id: String, withImage image: UIImage) {
        if let index = self.artists.firstIndex(where: { $0.id == id }) {
            self.artists[index].avatarImage = image
        }
        else {
            print("Artist lookup failed in updateArtistImage.")
        }
    }
}
