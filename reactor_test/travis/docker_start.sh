cd docker_build
docker pull 721039963787.dkr.ecr.eu-central-1.amazonaws.com/mpg-reactor-test
docker pull mariadb:10.2.43
docker-compose up -d
cd ..
