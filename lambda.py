import json
import requests

def lambda_handler(event,content):
payload = {
  "subnet_id": event['subnet_id'],
  "name": "Prathamesh",
  "email": "lawandprathamesh11@gmail.com"
}

payload=json.dumps(payload)

request_header={
    'X-Siemens-Auth': 'test'
    "Content-Type": "application/json"
}

response=requests.post('https://bc1yy8dzsg.execute-api.eu-west-1.amazonaws.com/v1/data',
                        headers=request_header,
                        data=payload)


 if response.status_code == 200:
    return {
      'statusCode': 200,
      'body': json.dumps({'message': 'The request was successful.'})
    }
  else:
    return {
      'statusCode': response.status_code,
      'body': json.dumps({'message': 'The request failed.'})
    }