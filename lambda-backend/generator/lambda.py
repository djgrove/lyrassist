import json, boto3, random
import botocore

def lambda_handler(event, context):
    # get the artist name from query params
    artist = event["queryStringParameters"]['artist']

    # ensure that there was valid input
    if (artist is None or artist == '' or len(artist) > 100):
        return {
            'statusCode': 400,
            'body': 'Error: Artist query string parameter was malformatted--either empty or too long.'
        }
    
    s3 = boto3.client('s3')
    bucket_name = '21pybots'
    filename = artist + '.json'

    markov_chain = loadMarkovFromS3(s3, bucket_name, filename)

    if markov_chain is None:
        return {
            'statusCode': 404,
            'body': 'Error: The artist you are trying to access is not in our collection.'
        }

    lyrics = generateSong(markov_chain)

    return {
        'statusCode': 200,
        'body': json.dumps({'data': lyrics})
    }

"""
    loads a pickle object stored as a file dump into s3
    params:
        s3 - S3 client connection
        bucket_name - name of the S3 bucket on AWS
        filename - artist.pkl for the given artist we are indexing
"""
def loadMarkovFromS3(s3, bucket_name, filename):
    download_path = '/tmp/' + filename

    try:
        s3.download_file(bucket_name, filename, download_path)
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