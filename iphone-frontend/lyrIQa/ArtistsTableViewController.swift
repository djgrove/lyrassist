//
//  ArtistsTableViewController.swift
//  lyrIQa
//
//  Created by Austin McInnis on 1/27/19.
//  Copyright © 2019 Austin McInnis. All rights reserved.
//

import UIKit

struct Artists: Codable {
    var artists: [Artist]
}

struct Artist: Codable {
    var name: String
    var data: String?
}

class ArtistCell: UITableViewCell {
    var artist: Artist?
}

class ArtistsTableViewController: UITableViewController {

    var artists = [Artist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if let path = Bundle.main.path(forResource: "lyriqa", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                
                // FIXME: Restructure JSON
                let decoder = JSONDecoder()
                let artistDict = try decoder.decode([String:[String:[String:String]]].self, from: data)
                if let artists = artistDict["artists"] {
                    for artist in artists {
                        print(artist)
                        let name = artist.key
                        let entry = artist.value
                        let data = entry["data"]
                        self.artists.append(Artist(name: name, data: data))
                    }
                }
                self.artists = self.artists.sorted(by: { $0.name < $1.name })
                self.tableView.reloadData()
            }
            catch let jsonError {
                fatalError("\(jsonError.localizedDescription)")
            }
        }
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
                    artistVC.artist = cell.artist
                }
            }
        }
    }
}
