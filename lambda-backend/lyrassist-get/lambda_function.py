import json
from botocore.vendored import requests

def getArtist(artist_id):
    url = 'https://firestore.googleapis.com/v1beta1/projects/lyrassist-f665f/databases/(default)/documents/artists/' + artist_id
    
    res = requests.get(url)
    if res.status_code == 404:
        return None
    data = res.json()
    
    artist = {
        'name': data['fields']['name']['stringValue'],
        'photo': data['fields']['photo']['stringValue'],
        'bio': data['fields']['bio']['stringValue'],
    }
    
    return artist

def lambda_handler(event, context):
    artist_id = event["queryStringParameters"]['artist']
    if artist_id == '':
         return {
            'statusCode': 400,
            'body': json.dumps({
                'errorMsg': 'Error: You did not provide an artist_id.',
            })
        }
        
    artist = getArtist(artist_id)
    
    if artist is None:
        return {
            'statusCode': 404,
            'body': json.dumps({
                'errorMsg': 'Error: The artist you are trying to access is not in our collection.',
            })
        }

    return {
        'statusCode': 200,
        'body': json.dumps({
            'name': artist['name'],
            'photo': artist['photo'],
            'bio': artist['bio'],
        }),
        # need this header to enable CORS manually since API gateway is using Lambda proxy integration
        'headers': {
            "Access-Control-Allow-Origin": "*"
        }
    }