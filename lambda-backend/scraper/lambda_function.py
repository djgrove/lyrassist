import json, re, boto3, botocore
from botocore.vendored import requests
from bs4 import BeautifulSoup

def lambda_handler(event, context):
    artist_link = event['url']
    bucket_name = '21pybots'
    
    if artist_link == None:
        return {
            'statusCode': 400,
            'body': "Error: you did not provide a url to scrape."
        }
    
    base_url = 'http://www.mldb.org/'

    # parse artist name from the link
    artist = artist_link.split('-', 2)[2].split('.')[0]
    all_lyrics = []

    response = requests.get(artist_link)
    soup = BeautifulSoup(response.text, 'html.parser')

    songs = soup.find("table", {"id": "thelist"})

    for link in songs.findAll('a'):
        # validate that it's a song link
        if 'song' in link['href']:
            print 'Grabbing lyrics at ' + link['href'] + '...'

            response = requests.get(base_url + link['href'])
            soup = BeautifulSoup(response.text, 'html.parser')
            lyrics = soup.find("p", {"class": "songtext"}).text

            # remove artist credits if included
            if 'Written by' in lyrics:
                lyrics = lyrics.split('Written by', 1)[1].split("\n", 2)[2]

            # strip html tags, and make sure the lyrics are utf 8 encoded
            lyrics = re.sub("[^<]+?>", '', lyrics.encode('utf-8'))
            all_lyrics.append(lyrics)

    generateJSONCachedFile(artist, all_lyrics, bucket_name)
    return {
        'statusCode': 200,
        'body': "Successfully generated cached JSON file for" + artist_link
    }

# creates a JSON dump in the cache for the given artist
def generateJSONCachedFile(artist, songLyrics, bucket_name):
    filename = artist + '.json'

    markov = generateMarkov(songLyrics)
    artistSanitized = artist.lower().replace(' ', '-')
    s3 = boto3.client('s3')
    upload_path = '/tmp/' + artist + '.json'
    json.dump(markov, open(upload_path, "wb"))

    s3.upload_file(upload_path, bucket_name, filename)

    return True

# creates a Markov chain model given the entire lyrics set of the artist
def generateMarkov(lyrics):
    chain = {'<START>': []}
    
    for lyric in lyrics:
        words = lyric.replace('\n', ' <N> ').split(' ')
        words.append('<END>')
        chain['<START>'].append(words[0])
        
        for i, word in enumerate(words):
            # this should catch the out of bounds index
            if word == '<END>':
                break
            elif word in chain:
                chain[word].append(words[i + 1])
            else:         
                chain[word] = [words[i + 1]]
        
    return chain