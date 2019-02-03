import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class DataService {

  constructor(private http: HttpClient) { }

  getArtists() {
    return this.http.get('https://1iou0tajke.execute-api.us-east-2.amazonaws.com/prod/list')
  }

  getLyrics(artist : string) {
    return this.http.get<{data: string[]}>('https://1iou0tajke.execute-api.us-east-2.amazonaws.com/prod/generate?artist=' + artist)
  }

}
