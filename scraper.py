import requests, json, re, pickle, sys
from bs4 import BeautifulSoup

def main():
    base_url = 'http://www.mldb.org/'
    # accept the artist link to scrape as user input
    artist_link = sys.argv[1]

    # parse artist name from the link
    artist = artist_link.split('-', 2)[2].split('.')[0]
    all_lyrics = []

    response = requests.get(artist_link)
    soup = BeautifulSoup(response.text, 'lxml')

    songs = soup.find("table", {"id": "thelist"})

    for link in songs.findAll('a'):
        # validate that it's a song link
        if 'song' in link['href']:
            print 'Grabbing lyrics at ' + link['href'] + '...'

            response = requests.get(base_url + link['href'])
            soup = BeautifulSoup(response.text, 'lxml')
            lyrics = soup.find("p", {"class": "songtext"}).text

            # remove artist credits if included
            if 'Written by' in lyrics:
                lyrics = lyrics.split('Written by', 1)[1].split("\n", 2)[2]

            # strip html tags, and make sure the lyrics are utf 8 encoded
            lyrics = re.sub("[^<]+?>", '', lyrics.encode('utf-8'))
            all_lyrics.append(lyrics)

    generatePickle(artist, all_lyrics)

# creates a pickle dump in the cache for the given artist
def generatePickle(artist, songLyrics):
    print 'Generating Markov chain for ' + artist

    markov = generateMarkov(songLyrics)
    artistSanitized = artist.lower().replace(' ', '-')
    pickle.dump(markov, open('cache/' + artist + '.pkl', "wb"))

    print 'Pickle was dumped'
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

main()