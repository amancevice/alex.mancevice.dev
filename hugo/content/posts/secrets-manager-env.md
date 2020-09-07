---
title: Injecting SecretsManager into the Lambda Runtime ENV
date: 2019-02-10
draft: false
toc: true
images:
tags:
  - AWS
  - SecretsManager
  - Lambda
  - Serverless
---

AWS SecretsManager is a service that allows you to store encrypted secrets in the cloud as raw strings or JSON docs.

Storing secrets as JSON allows you to store ENV settings, similar to a .env file.

Using the AWS SDK for Lambda runtimes, we can update our application's process.env with the encrypted environment.

## NodeJS Runtime

Using the promise-ified version of the getSecretValue() function, we can update the process.env object with the response of the AWS resource.

```javascript
const exportSecret = (client, options) => {
  client.getSecretValue(options).promise().then((res) => {
    Object.assign(process.env, JSON.parse(res.SecretString));
  });
};

const {SecretsManager} = require('aws-sdk');
const AWS_SECRET = process.env.AWS_SECRET;
const secretsmanager = new SecretsManager();

exportSecret(secretsmanager, {SecretId: AWS_SECRET});

exports.handler = async (event, context) => {
  // ...
};
```

### With Serverless Express

When deploying express apps to AWS Lambda you can establish your ENV before handling the HTTP request.

```javascript
const exportSecret = (client, options) => {
  client.getSecretValue(options).promise().then((res) => {
    Object.assign(process.env, JSON.parse(res.SecretString));
  });
};

const {SecretsManager} = require('aws-sdk');
const AWS_SECRET = process.env.AWS_SECRET;
const secretsmanager = new SecretsManager();

exportSecret(secretsmanager, {SecretId: AWS_SECRET});

let server;

const createServer = async (app) => {
  server = awsServerlessExpress.createServer(app);
  return server;
}

exports.handler = async (event, context) => {
  const app = require('./app');
  await Promise.resolve(server || createServer(app));
  return await awsServerlessExpress.proxy(server, event, context, 'PROMISE').promise;
};
```

## Python Runtime

```python
import json
import os

import boto3

def export_secret(client, **params):
    secret = client.get_secret_value(**params)
    string = secret['SecretString']
    values = json.loads(string)
    os.environ.update(**values)
    return values

SECRETSMANAGER = boto3.client('secretsmanager')
AWS_SECRET = os.getenv('AWS_SECRET')

export_secret(SECRETSMANAGER, SecretId=AWS_SECRET)

def handler(event, context):
    print(f'EVENT {json.dumps(event)}')
```

## Ruby Runtime

```ruby
require "json"

require "aws-sdk-secretsmanager"

def export_secret(client, **options)
  secret = client.get_secret_value(**options)
  string = secret["SecretString"]
  values = JSON.parse(string)
  values.tap{|values| ENV.update(**values) }
end

export_secret(Aws::SecretsManager.new, secret_id: ENV["AWS_SECRET"])

def handler(event:, context:)
  puts "EVENT #{event.to_json}"
end
```
