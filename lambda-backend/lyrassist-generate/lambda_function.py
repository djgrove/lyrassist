import json, boto3, random
import botocore
from botocore.vendored import requests

def lambda_handler(event, context):
    # get the artist name from query params
    artist_id = event["queryStringParameters"]['artist']

    # ensure that there was valid input
    if (artist_id is None):
        return {
            'statusCode': 400,
            'body': 'Error: Artist was not provided.'
        }
    
    s3 = boto3.client('s3')
    bucket_name = 'lyrassist-data'
    path = artist_id + '/markov.json'

    markov_chain = loadMarkovFromS3(s3, bucket_name, path)

    if markov_chain is None:
        return {
            'statusCode': 404,
            'body': json.dumps({'errorMsg': 'Error: The artist you are trying to access is not in our collection.'})
        }

    lyrics = generateSong(markov_chain)

    return {
        'statusCode': 200,
        'body': json.dumps({
            'lyrics': lyrics
        }),
        # need this header to enable CORS manually since API gateway is using Lambda proxy integration
        'headers': {
            "Access-Control-Allow-Origin": "*"
        },
    }

"""
    loads a pickle object stored as a file dump into s3
    params:
        s3 - S3 client connection
        bucket_name - name of the S3 bucket on AWS
        filename - artist.pkl for the given artist we are indexing
"""
def loadMarkovFromS3(s3, bucket_name, filepath):
    download_path = '/tmp/markov.json'

    try:
        s3.download_file(bucket_name, filepath, download_path)
    except botocore.exceptions.ClientError as e:
        code = e.response['Error']['Code']
        # weirdly, seems like we get 403 forbidden errors when the object isn't in my s3 bucket
        if code == "404" or code == "403" :
            return None
        else:
            # something else mysterious happened
            raise

    file = open(download_path, 'rb')
    chain = json.load(file)
    file.close()

    return chain

# TODO: add formal song structure
def generateSong(chain):
    words = []
    # generate the first word in the lyrics
    word = random.choice(chain['<START>'])
    words.append(word)

    # keep generating lyrics
    while not word == '<END>':
        word = random.choice(chain[word])
        words.append(word)

    # join the words together into a string with line breaks
    lyrics = " ".join(words[:-1])
    return "\n".join(lyrics.split("<N>"))