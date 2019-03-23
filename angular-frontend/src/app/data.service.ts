import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class DataService {

  constructor(private http: HttpClient) { }

  getArtists() {
    return this.http.get('https://ffpy6gqw9j.execute-api.us-west-1.amazonaws.com/prod/list')
  }

  getLyrics(artistID : string) {
    return this.http.get<{data: string[]}>('https://ffpy6gqw9j.execute-api.us-west-1.amazonaws.com/prod/generate?artist=' + artistID)
  }
}