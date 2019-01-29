import { Component, OnInit } from '@angular/core';
import { DataService } from '../data.service';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss']
})
export class HomeComponent implements OnInit {

  artists : Object;

  constructor(private data: DataService) { }

  ngOnInit() {
    this.data.getArtists().subscribe(data => {
      this.artists = data
      console.log(this.artists)
    })
  }

}
