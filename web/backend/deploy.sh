#!/bin/bash
echo "Deploying backend..."
zip -r function.zip index.js node_modules/
aws lambda update-function-code \
    --function-name yonghyun-test \
    --zip-file fileb://function.zip
rm function.zip
echo "Backend deployed!"