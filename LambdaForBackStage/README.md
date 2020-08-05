following https://learn.hashicorp.com/terraform/aws/lambda-api-gateway

Step of deployment
```
cd example

zip ../example.zip main.js
zip zip ../example.zip -r node_modules
zip ../example.zip package-lock.json

cd ..

terraform init

terraform apply
```


After creating the func and before the api gateway, can verify the output using:


```
aws lambda invoke --region=us-east-1 --function-name=ServerlessExample output.txt
{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}
```

