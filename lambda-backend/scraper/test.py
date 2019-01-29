import requests, json


def lambda_handler(event, context):
    artist = event
    api_url = "https://musixmatchcom-musixmatch.p.rapidapi.com/wsr/1.1/track.search?f_has_lyrics=1&q_artist=" + artist + "&page_size=100&page=1"

    response = requests.get(api_url,
        headers={
            "X-RapidAPI-Key": "0b360fae8fmshd4b4ee351c8651ep17edaejsnc7de30545f04"
        }
    )

    data = json.loads(response.text)
    bad = ['live', 'remix', 'acoustic', 'edit', 'version', 'bootleg', 'instrumental']

    for song in data:
        title = song['track_name'].lower()
        # TODO this seems very inefficient
        if not any(x in title for x in bad):
            print(title)

lambda_handler("coldplay", "test")