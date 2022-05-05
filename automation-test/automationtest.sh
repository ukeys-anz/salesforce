#!/bin/bash
# Install dependencies for ARM architecture
arch=$(dpkg --print-architecture)
if  [[ $arch == arm* ]]
then
    npm i @ffmpeg-installer/linux-arm64
fi

npm install
ls -al

# below code is used for debugging network traffic
# sudo tcpdump -s 65535 -w out.pcap &

# Start chromedriver
echo "START CHROMEDRIVER"
chromedriver --port=9515 --log-path=/app/chromedriver.log &
sleep 5
ps ax
netstat -an
# Build ts and utam
echo "BUILD THE TESTS"
npm run-script build:utam
npm run-script build:ts

# Run test scripts
echo "RUN WDIO TEST"
npx wdio run wdio.conf.js