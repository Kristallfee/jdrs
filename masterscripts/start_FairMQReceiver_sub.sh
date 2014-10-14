#!/bin/bash

if(false); then
    buffSize="50000000" # nanomsg buffer size is in bytes
else
    buffSize="1000" # zeromq high-water mark is in messages
fi


ID="301"
numIoThreads="1"
inputSocketType="sub"
inputRcvBufSize=$buffSize
inputMethod="connect"
inputAddress="tcp://localhost:5566"
bigcounter="0"
xterm -hold -e  $JDRSPATH/build_software/FairMQ_Receiver/run_topix4_fairmq_receiver  $ID $numIoThreads $inputSocketType $inputRcvBufSize $inputMethod $inputAddress $bigcounter &
