#!/bin/bash
# Script to convert OTA captured .ts files to .mp4
# Uses: https://hub.docker.com/r/jlesage/handbrake

log=/var/log/$(basename $0 |cut -f1 -d'.').log

logmessage() {
  timestamp=$(date '+%b %d %T')
  echo $timestamp "$1" >> $log
}

# Check if transcoder is currently running
proctest=$(ps -ef |grep Transcoder |grep -v grep)
if [ -n "$proctest" ]
then
  logmessage "Transcoder currently running - exiting"
  exit 1
fi

# Check if there is any work to do
if [ -z "$(find /dvr/ /plex/tv/ -name "*.ts" -type f)" ]; then
  logmessage "No transport stream files to process"
  exit 0
fi

# Convert the files
for file in $(find /dvr/ /plex/tv/ -name "*.ts" -type f |tr " " _)
do
  # Start Handbrake container
  docker compose -f /docker/handbrake/docker-compose.yml up -d
  file2convert=$(echo "${file}" |tr _ " ")
  destfilename="${file2convert%.ts}.mp4"
  logmessage "Converting ${file2convert}"
  docker exec -i handbrake-handbrake-1 HandBrakeCLI -i "/storage/${file2convert}" -o "/storage/${destfilename}" --preset="Devices/Apple 1080p30 Surround" --encoder-preset="veryfast" -O && rm -f "${file2convert}" || echo "Error converting ${file2convert}"
  logmessage "Status of ${file2convert} conversion = $?"
  chown plex:plex "${destfilename}"
  # Stop Handbrake container
  docker compose -f /docker/handbrake/docker-compose.yml stop
done
