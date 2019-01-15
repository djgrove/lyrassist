import { Component } from '@angular/core';
import { SwUpdate } from '@angular/service-worker'
import { DataService } from './data.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  title = 'twenty one pybots';

  song : any;

  constructor(updates: SwUpdate, private data: DataService ) {
    updates.available.subscribe(event => {
      updates.activateUpdate().then(() => document.location.reload());
    })
  }

  ngOnInit() {
    this.data.getSong().subscribe(res => {
      this.song = res;
      console.log(this.song);
    })
  }
}
