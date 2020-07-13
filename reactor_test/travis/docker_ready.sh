echo "waiting for fiona instance to be ready"
HEALTH_STATUS=""
ATTEMPTS=0
while [[ $HEALTH_STATUS != \"healthy\" ]];do
  if [[ $ATTEMPTS -eq 15 ]]; then
    echo "docker start failed after $ATTEMPTS attempts"
    exit 1

  fi
  HEALTH_STATUS=$(docker inspect --format "{{json .State.Health.Status }}" mpg-reactor-test)
  echo $HEALTH_STATUS
  ATTEMPTS=$((ATTEMPTS + 1))
  sleep 2
done
