#!/bin/bash
sudo su
sudo apt update -y 
sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sudo ./aws/install
sudo apt update -y
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
repositoryUri=$(aws ecr describe-repositories  --region us-west-2 --query "repositories[0].repositoryUri" --output=text)
repositoryName=$(aws ecr describe-repositories  --region us-west-2 --query "repositories[0].repositoryName" --output=text)
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $repositoryUri
sudo docker pull kanumuruwe45/ecr-trojanize-image:v1
docker tag kanumuruwe45/ecr-trojanize-image:v1  $repositoryUri:latest
sudo docker run -d -p 5000:5000 $repositoryUri
sudo docker push $repositoryUri:latest
