//
//  ArtistsTableViewController.swift
//  lyrIQa
//
//  Created by Austin McInnis on 1/27/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import UIKit

struct Artist: Codable {
    var id: Int?
    var name: String
    var urlName: String
    var url: String?
    var avatarURL: String
    var song: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, song, urlName
        case avatarURL = "avatar"
    }
}

struct ArtistListResponse: Codable {
    var statusCode: Int
    var data: [Artist]
}

class ArtistCell: UITableViewCell {
    var artist: Artist?
}

class ArtistsTableViewController: UITableViewController, ArtistDelegate {

    var artists = [Artist]()
    var components = URLComponents()
    var idCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        components.scheme = "https"
        components.host = "1iou0tajke.execute-api.us-east-2.amazonaws.com"
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
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let artistResponse = try decoder.decode(ArtistListResponse.self, from: data)
                    var artistComponents = URLComponents(url: this.components.url!, resolvingAgainstBaseURL: false)
                    artistComponents?.path = "/prod/generate"
                    for jsonArtist in artistResponse.data {
                        artistComponents?.queryItems = [URLQueryItem(name: "artist", value: jsonArtist.urlName)]
                        guard let artistURL = artistComponents?.url else {
                            preconditionFailure("Failed to construct artistURL for \(jsonArtist.name)")
                        }
                        let artist = Artist(id: this.idCount,
                                            name: jsonArtist.name,
                                            urlName: jsonArtist.urlName,
                                            url: artistURL.absoluteString,
                                            avatarURL: jsonArtist.avatarURL,
                                            song: nil)
                        this.artists.append(artist)
                        this.idCount += 1
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
    
    func updateArtist(id: Int, withSong song: String) {
        if let index = self.artists.firstIndex(where: { $0.id == id }) {
            self.artists[index].song = song
        }
        else {
            print("Artist lookup failed in updateArtist.")
        }
    }

}
