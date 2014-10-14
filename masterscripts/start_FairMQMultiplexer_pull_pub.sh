#!/bin/bash

if(false); then
    buffSize="50000000" # nanomsg buffer size is in bytes
else
    buffSize="1000" # zeromq high-water mark is in messages
fi

ID="201"
numIoThreads="1"
inputSocketType="pull"
inputRcvBufSize=$buffSize
inputMethod="bind"
inputAddress="tcp://*:5565"
outputSocketType="pub"
outputSndBufSize=$buffSize
outputMethod="bind"
outputAddress="tcp://*:5566"
xterm -hold -e $FAIRROOTBUILDPATH/bin/proxy $ID $numIoThreads $inputSocketType $inputRcvBufSize $inputMethod $inputAddress $outputSocketType $outputSndBufSize $outputMethod $outputAddress &
