import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class DataService {

  constructor(private http : HttpClient) { }

  getSong() {
    return this.http.get('https://1iou0tajke.execute-api.us-east-2.amazonaws.com/prod/generate2?artist=metallica');
  }
}
