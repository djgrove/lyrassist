# LyrAssist

LyrAssist is a web app that uses a Markov Chain model to produce song lyrics in the style of a particular artist.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites
#### Install Docker:
* On a Mac/Windows machine: (https://www.docker.com/get-started)
* On Linux: 
```
apt-get install docker
```
#### Install Node (npm)
* On Mac:
```
brew install node
```
* On Linux:
```
apt-get install node
```
#### Install Git
```
brew install git
```
or
```
apt-get install git
```

### Installing and building the project
* Clone the project:
```
git clone https://github.com/djgrove/lyrassist
```

* Switch to the project folder (replace "lyrassist" if you used a custom folder name):
```
cd lyrassist
```

* Use [docker-compose](https://docs.docker.com/compose/) to build the frontend for the project:
```
docker-compose up
```

After the command completes, the project should serve at (http://localhost).

If you a **502 Bad Gateway** error, this indicates that the Nginx container has started but the Node container running the Angular app has not yet finished launching, so retry after a few moments.

## Running tests

We will be working on developing a test suite soon.

## Built With

* [Angular 7](https://angular.io/docs/) - Front-end JavaScript framework used
* [AWS Lambda](https://aws.amazon.com/lambda/) - Backend serverless environment
* [Firebase](https://firebase.google.com/) - NoSQL realtime database

## Authors

* **Devon Grove** - *Web frontend/backend* - [djgrove](https://github.com/djgrove)
* **Austin McInnis** - *iOS* - [amcinnis](https://github.com/amcinnis)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Additional Notes
* This project is entirely non-profit and it will remain that way.
### Acknowledgements
* [Genius](https://genius.com)
* [Last.fm](https://last.fm)
### Documentation/References Followed
* We've deployed to the "www" subdomain as opposed to a naked "lyrassist.app" domain, based on the rationale provided [here](https://www.jackkinsella.ie/articles/www-vs-naked-domain) and [here](https://www.jackkinsella.ie/articles/www-vs-naked-domain). 
* HTTPS was enabled via an Amazon Certificate Manager (ACM) SSL cert and and AWS CloudFront distribution CDN using a guide followed [here](https://rynop.com/2017/04/20/howto-serve-angular2-app-from-s3-and-cloudfront-with-free-https/)
