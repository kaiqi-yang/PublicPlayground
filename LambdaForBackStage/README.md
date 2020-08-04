following https://learn.hashicorp.com/terraform/aws/lambda-api-gateway

Step of build
```
cd example

zip ../example.zip main.js

```


After creating the func, can verify the output using:


```
aws lambda invoke --region=us-east-1 --function-name=ServerlessExample output.txt
{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}
```

