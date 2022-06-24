#!/bin/bash
# Install dependencies for ARM architecture
arch=$(dpkg --print-architecture)
if  [[ $arch == arm* ]]
then
    npm i @ffmpeg-installer/linux-arm64
fi

npm install

# below code is used for debugging network traffic
# sudo tcpdump -s 65535 -w out.pcap &

# Start chromedriver
echo "START CHROMEDRIVER"
echo "=================="
echo ""
chromedriver --port=9515 --log-path=/app/chromedriver.log &
sleep 5
ps ax
netstat -an
echo ""

# Build ts and utam
echo "BUILD THE TESTS"
echo "=================="
echo ""
npm run build
echo ""

# Run test scripts
echo "RUN WDIO TEST"
echo "=================="
echo ""
npm run test
echo ""

# Generate test report
echo "GENERATE ALLURE REPORT"
echo "=================="
echo ""
npm run result:generate
echo ""