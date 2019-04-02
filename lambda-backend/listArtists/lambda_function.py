import json, botocore, boto3, os
from botocore.vendored import requests
#import firebase_admin
#from firebase_admin import credentials
#from firebase_admin import firestore

def lambda_handler(event, context):
    '''cred = credentials.Certificate('credentials.json')
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    
    artists = db.collection('artists').get()'''
    res = requests.get('https://firestore.googleapis.com/v1beta1/projects/lyrassist-f665f/databases/(default)/documents/artists')

    artists = res.json()['documents']

    artists_list = []
    
    for artist in artists:
        artists_list+=[{
            'artist_id' : artist['name'].split('/')[:-1],
            'name' : artist['fields']['name']['stringValue'],
            'avatar' : artist['fields']['photo']['stringValue']
        }]
    
    
    return {
        'statusCode': 200,
        'data': artists
    }