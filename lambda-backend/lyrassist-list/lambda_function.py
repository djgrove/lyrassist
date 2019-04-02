import json, botocore, boto3
from botocore.vendored import requests

def lambda_handler(event, context):
    res = requests.get('https://firestore.googleapis.com/v1beta1/projects/lyrassist-f665f/databases/(default)/documents/artists')

    artists = res.json()['documents']

    artists_data = []
    
    for artist in artists:
        artists_data+=[{
            'artist_id' : artist['name'].split('/')[-1],
            'name' : artist['fields']['name']['stringValue'],
            'avatar' : artist['fields']['photo']['stringValue']
        }]

    # TODO: rm sort once artist lookup done via a search feature on frontend
    artists_data.sort(key=lambda k: k['name'])
    
    return {
        'statusCode': 200,
        'data': artists_data
    }