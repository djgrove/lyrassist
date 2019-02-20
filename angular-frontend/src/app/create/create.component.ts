import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { DataService } from '../data.service';

@Component({
  selector: 'app-create',
  templateUrl: './create.component.html',
  styleUrls: ['./create.component.scss']
})
export class CreateComponent implements OnInit {
  artistID : string
  artist : Object

  constructor(private route: ActivatedRoute, private data: DataService) {}

  ngOnInit() {
    // get the artist name url parameter from the router
    this.route.paramMap.subscribe(params => {
      this.artistID = params.get('artist_id')
    });

    // request lyrics for this artist from our REST API
    this.data.getLyrics(this.artistID).subscribe(data => {
      this.artist = data
    })
  }

}
