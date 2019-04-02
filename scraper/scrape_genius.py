# Standard Python libraries
import requests, time, json, re, yaml

# Scraping tools
from bs4 import BeautifulSoup
from selenium import webdriver

# AWS SDK
import boto3
from botocore.exceptions import ClientError

# Firebase
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

SONG_REQUEST_DELAY = 1

"""
Validates if an artist already exists in our database

:param firebaseDB: a Firebase Cloud Firestore client object
:param artistName: the name of the artist we are trying to add -- it is assumed that this WILL be unique for each artist even though it isn't a primary key
:returns: the ID of the artist if they exist, otherwise None
"""
def getLastFMData(artistName):
    conf = yaml.load(open('credentials.yml'))
    apiKey = conf['lastfm_api']['key']

    response = requests.get("https://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=" + artistName + "&api_key=" + apiKey +"&format=json")
    data = json.loads(response.content)

    return {
        'photo': data['artist']['image'][2]['#text'],
        'bio': data['artist']['bio']['summary']
    }

"""
Validates if an artist already exists in our database

:param firebaseDB: a Firebase Cloud Firestore client object
:param artistName: the name of the artist we are trying to add -- it is assumed that this WILL be unique for each artist even though it isn't a primary key
:returns: the ID of the artist if they exist, otherwise None
"""
def artistExists(firebaseDB, artistName):
    artistID = None
    artistsRef = firebaseDB.collection('artists')

    # check if the generator returned by the firestore query hast anything in it
    for artist in artistsRef.where("name", "==", artistName).get():
        artistID = artist.id
        break
    
    return artistID

"""
This function will use Selenium to perform the tricky logic of accessing JavaScript controlled album info, and grab all links

:param artist: the full name of an artist to be added to the collection
:returns: the ID of the artist in our firebase database
"""
def addArtisttoDB(artistName):
    data = {}
    artistRef = None
    # use a service account to authenticate
    cred = credentials.Certificate('credentials.json')
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    # check if the artist has already been added to our database
    artistID = artistExists(db, artistName)
    if artistID is None:
        lastFM = getLastFMData(artistName)
        data.update({
            'name': artistName,
            'bio': lastFM['bio'],
            'photo': lastFM['photo'],
        })

        # create a new artist and get key
        artistRef = db.collection('artists').document()
    else:
        # get the ref to the already existing artist
        artistRef = db.collection('artists').document(artistID)

    data.update({'last_updated': firestore.SERVER_TIMESTAMP})
    artistRef.set(data)

    return artistRef.id

"""
This function will use Selenium to perform the tricky logic of accessing JavaScript controlled album info, and grab all links

:param artist_name: an artist to scrape lyrics for, entered at the command line
:returns: a list of valid album URLs for the top Genius artist result for provided artist
"""
def getArtistAlbumLinks(artistName):
    mybrowser = webdriver.Chrome("./chromedriver") # Browser and path to Web driver you wish to automate your tests cases.
    artistSanitized = artistName.replace(" ","+")
    baseURL = "https://genius.com/search?q=" + artistSanitized # Append User_Input to search query
    mybrowser.get(baseURL) # Open in browser

    # wait for the ad to load so it doesn't f up your click
    time.sleep(2)
    # go to artist page for first result
    mybrowser.find_element_by_class_name("mini_card").click()
    time.sleep(1)

    # get to bottom of page so "see all albums" link appears and click it
    mybrowser.execute_script("window.scrollBy(0,2000)")
    time.sleep(4) # wait for ad overlay to go away
    ALBUM_BUTTON_INDEX = 1
    mybrowser.find_elements_by_class_name('full_width_button')[ALBUM_BUTTON_INDEX].click()
    
    # load the divs in the album list
    time.sleep(1)
    html = mybrowser.find_elements_by_tag_name('scrollable-data')[1].get_attribute('innerHTML')
    mybrowser.close()
    soup = BeautifulSoup(html, "html.parser")

    albums = []
    for album in soup.find_all('a'):
        albums.append(album['href'])

    return albums

def sanitzieLyrics(lyrics):
    return re.sub("[^<]+?>", '', lyrics)

"""
This function will get the lyrics at an associated song URL on genius.com and add them to the markov chain

:param song_link: the full URL path for the desired song
:param markov: the current markov chain to continue modifying
"""
def addSongToMarkov(song_link, markov):
    print("Adding song at link: " + song_link + "to Markov chain")

    soup = BeautifulSoup(requests.get(song_link).content, "html.parser")
    lyrics = soup.find('div', class_="lyrics").text
    lyrics = sanitzieLyrics(lyrics)
    words = lyrics.replace('\n', ' <N>').split(' ')
    words.append('<END>')
    
    markov['<START>'].append(words[0])
    for i, word in enumerate(words):
        # this should catch the out of bounds index
        if word == '<END>':
            break
        elif word in markov:
            markov[word].append(words[i + 1])
        else:         
            markov[word] = [words[i + 1]]

"""
Uploads a pre-generated Markov model to a file on s3

:param markov: the Markov chain (as a python dictionary) to upload
:param artist_id: the ID of the artist in our firebase database
:returns: true if upload succeeded, else false
"""
def uploadMarkovModel(markov, artist_id):
    data = json.dumps(markov)
    
    try:
        s3 = boto3.resource('s3')    
        s3.Bucket('lyrassist-data').put_object(
            Key=artist_id+'/markov.json',
            Body=data
        )
    except Clienterror as e:
        return False

    return True

"""
Scrapes an artist's lyrics collection from Genius.com, 

:param song_link: the full URL path for the desired song
"""
def main():
    artistName = input("Enter Artist Name = ") # User_Input = Artist Name
    artistID = addArtisttoDB(artistName)

    albums = getArtistAlbumLinks(artistName)
    markov = {'<START>': []}

    # go through each song in each album and add it to the markov model
    for album in albums:
        soup = BeautifulSoup(requests.get(album).content, "html.parser")

        for song in soup.find_all('a', class_="u-display_block"):
            addSongToMarkov(song['href'], markov)
            time.sleep(SONG_REQUEST_DELAY)

    uploadMarkovModel(markov, artistID)

main()