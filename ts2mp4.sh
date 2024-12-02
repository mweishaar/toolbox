#!/bin/bash
# Script to convert OTA captured .ts files to .mp4
# Uses: https://hub.docker.com/r/jlesage/handbrake

# Check if transcoder is currently running
proctest=$(ps -ef |grep Transcoder |grep -v grep)
if [ -n "$proctest" ]
then
  echo "Transcoder currently running - exiting"
  exit 1
fi

# Check if there is any work to do
if [ -z $(find /dvr/ /plex/tv/ -name "*.ts" -type f) ]; then
  echo "No transport stream files to process"
  exit 0
fi

# Bring up docker container
docker compose -f /docker/handbrake/docker-compose.yml up -d

for file in $(find /dvr/ /plex/tv/ -name "*.ts" -type f |tr " " _)
do
  file2convert=$(echo "${file}" |tr _ " ")
  destfilename="${file2convert%.ts}.mp4"
  echo "Converting ${file2convert}"
  docker exec -it handbrake-handbrake-1 HandBrakeCLI -i "/storage/${file2convert}" -o "/storage/${destfilename}" --preset="Devices/Apple 1080p30 Surround" --encoder-preset="veryfast" -O && rm -f "${file2convert}" || echo "Error converting ${file2convert}"
done

# Shut down docker container
docker compose -f /docker/handbrake/docker-compose.yml down
