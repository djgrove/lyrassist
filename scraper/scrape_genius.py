# Standard Python libraries
import requests, time, json, re

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

def getLastFMBio(artist):
    return "placeholder"

"""
This function will use Selenium to perform the tricky logic of accessing JavaScript controlled album info, and grab all links

:param artist: the full name of an artist to be added to the collection
:returns: the ID of the artist in our firebase database
"""
def addArtisttoDB(artist):
    # use a service account to authenticate
    cred = credentials.Certificate('credentials.json')
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    # check if the artist exists and has been modified recently
    #results = db.orderByChild('name').equalTo(artist)
    #if db.orderByChild('name').equalTo(artist):
       #return results[0].id

    # set the fields
    data = {
        'name': artist,
        'bio': getLastFMBio(artist)
    }

    # create a new artist and get key
    firebase_ref = db.collection(u'artists').document()
    firebase_ref.set(data)
    artist_id = firebase_ref.id

    return artist_id

"""
This function will use Selenium to perform the tricky logic of accessing JavaScript controlled album info, and grab all links

:param artist_name: an artist to scrape lyrics for, entered at the command line
:returns: a list of valid album lioks for the top Genius artist result for provided artist
"""
def getArtistAlbumLinks(artist_name):
    mybrowser = webdriver.Chrome("./chromedriver") # Browser and path to Web driver you wish to automate your tests cases.
    artist_sanitized = artist_name.replace(" ","+")
    base_url = "https://genius.com/search?q="+artist_sanitized # Append User_Input to search query
    mybrowser.get(base_url) # Open in browser

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
    user_input = input("Enter Artist Name = ") # User_Input = Artist Name

    artist_id = addArtisttoDB(user_input)

    albums = getArtistAlbumLinks(user_input)
    markov = {'<START>': []}

    # go through each song in each album and add it to the markov model
    for album in albums:
        soup = BeautifulSoup(requests.get(album).content, "html.parser")

        for song in soup.find_all('a', class_="u-display_block"):
            addSongToMarkov(song['href'], markov)
            time.sleep(SONG_REQUEST_DELAY)

    uploadMarkovModel(markov, artist_id)

main()

'''
cred = credentials.Certificate('credentials.json')
firebase_admin.initialize_app(cred)
db = firestore.client()
artists = db.collection('artists').get()

for artist in artists:
    print(artist.id)'''