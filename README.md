# SQL Server in Docker

`SA` password is `rabota`

## Usage

docker run -d --name=sql --restart=always -p 1433:1433  --storage-opt size=512G -v "D:/Restore:C:/Restore" mac2000/mssql-docker

## Build

docker build . -t mac2000/mssql-docker

## Publish

docker login
docker push mac2000/mssql-docker