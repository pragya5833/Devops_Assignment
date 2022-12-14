echo "Starting to deploy docker image.."
DOCKER_IMAGE=848417356303.dkr.ecr.ap-south-1.amazonaws.com/vprof:latest
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 848417356303.dkr.ecr.ap-south-1.amazonaws.com
docker pull $DOCKER_IMAGE
docker ps -q --filter "expose=8080" | xargs -r docker stop
docker run --platform linux/amd64 -d -p 8080:8080 $DOCKER_IMAGE