#!/bin/bash

if(false); then
    buffSize="50000000" # nanomsg buffer size is in bytes
else
    buffSize="100" # zeromq high-water mark is in messages
fi


ID="501"
numIoThreads="1"
inputSocketType="sub"
inputRcvBufSize=$buffSize
inputMethod="connect"
inputAddress="tcp://localhost:5566"
xterm -e  /home/ikp1/esch/chip_readout/git_repository/jdrs/build-software-Desktop_Qt_5_3_GCC_64bit-Debug/DataMonitor/DataMonitor  $ID $numIoThreads $inputSocketType $inputRcvBufSize $inputMethod $inputAddress &


