#!/bin/bash

if(false); then
    buffSize="50000000" # nanomsg buffer size is in bytes
else
    buffSize="1000" # zeromq high-water mark is in messages
fi


# ID="101"
# eventSize="10000"
# eventRate="0"
# numIoThreads="1"
# outputSocketType="push"
# outputBufSize=$buffSize
# outputMethod="bind"
# outputAddress="tcp://*:5565"
# xterm -e /home/ikp1/esch/fairsoft/FairRoot_Mohammad_build/bin/testFLP $ID $eventSize $eventRate $numIoThreads $outputSocketType $outputBufSize $outputMethod $outputAddress &



ID="201"
numIoThreads="1"
inputSocketType="pull"
inputRcvBufSize=$buffSize
inputMethod="bind"
inputAddress="tcp://*:5565"
outputSocketType="push"
outputSndBufSize=$buffSize
outputMethod="bind"
outputAddress="tcp://*:5566"

xterm -e  /home/ikp1/esch/fairsoft/FairRoot_Mohammad_build/bin/testProxy $ID $numIoThreads $inputSocketType $inputRcvBufSize $inputMethod $inputAddress $outputSocketType $outputSndBufSize $outputMethod $outputAddress &



ID="301"
numIoThreads="1"
inputSocketType="pull"
inputRcvBufSize=$buffSize
inputMethod="connect"
inputAddress="tcp://localhost:5566"
xterm -hold -e  /home/ikp1/esch/chip_readout/git_repository/jdrs/build-software-Desktop_Qt_5_3_GCC_64bit-Debug/FairMQ_Receiver/run_topix4_fairmq_receiver  $ID $numIoThreads $inputSocketType $inputRcvBufSize $inputMethod $inputAddress &
