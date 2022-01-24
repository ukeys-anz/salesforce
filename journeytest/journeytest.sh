#!/bin/bash
# Install dependencies for ARM architecture
arch=$(dpkg --print-architecture)
if  [[ $arch == arm* ]]
then
    npm i @ffmpeg-installer/linux-arm64
fi

# Start chromedriver
echo "START CHROMEDRIVER"
chromedriver &

# Build ts and utam
echo "BUILD THE TESTS"
npm run-script build:utam
npm run-script build:ts

# Run test scripts
echo "RUN WDIO TEST"
npx wdio run wdio.conf.js