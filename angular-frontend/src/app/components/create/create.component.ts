import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { DataService } from '../../shared/services/data.service';


@Component({
  selector: 'app-create',
  templateUrl: './create.component.html',
  styleUrls: ['./create.component.scss']
})
export class CreateComponent implements OnInit {
  artist: Object;
  artistID: string;
  lyrics: string;

  constructor(private route: ActivatedRoute, private data: DataService) {}

  ngOnInit() {
    // get the artist ID from the router
    this.route.paramMap.subscribe(params => {
      this.artistID = params.get('artist_id');
    });

    // request artist bio and info
    this.data.getArtist(this.artistID).subscribe(data => {
      this.artist = data;
    });

    // request lyrics for this artist from our REST API
    this.data.getLyrics(this.artistID).subscribe(data => {
      // this.artistName = data['name']
      this.lyrics = data['lyrics'];
    });
  }
}
