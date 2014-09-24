#include "topix4_fairmq_receiver.h"
#include "mrfdata_8b.h"
#include "mrftools.h"
#include <boost/thread.hpp>
#include "FairMQLogger.h"
#include "../helper_functions.h"
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>

topix4_fairmq_receiver::topix4_fairmq_receiver():
    fEventSize(10000),
    fEventRate(1),
    fEventCounter(0),previous_dataword(0), previous_comandoword(0), bigcounter(false)
{
    writetofile = new WriteToFile();
}

topix4_fairmq_receiver::~topix4_fairmq_receiver()
{
    writetofile->Close();
    delete (writetofile);
}

void topix4_fairmq_receiver::SetBigCounter(string value)
{
    if(value == "1"){
        bigcounter =true;
    }
    else
    {
        bigcounter=false;
    }
}

void topix4_fairmq_receiver::Init()
{
    FairMQDevice::Init();
    writetofile->SetPathName("/private/esch/temp/");
    writetofile->OpenFile(atoi(FairMQDevice::fId.c_str()));
    writetofile->SetIntegerBase(16);
}

void topix4_fairmq_receiver::Run()
{
    LOG(INFO) << ">>>>>>> Run <<<<<<<";
    boost::thread rateLogger(boost::bind(&FairMQDevice::LogSocketRates, this));
    TMrfData_8b tempdaten;
    while ( fState == RUNNING){
        FairMQMessage* msg = fTransportFactory->CreateMessage();

        fPayloadInputs->at(0)->Receive(msg);
        int inputSize = msg->GetSize();
        tempdaten.setNumWords(inputSize);

        memcpy(reinterpret_cast<u_int8_t*>(&tempdaten.regdata[0]),msg->GetData(), msg->GetSize());

        Counter_Compare(tempdaten,previous_dataword,previous_comandoword, true, bigcounter ,writetofile, false );

        delete msg;
    }

    rateLogger.interrupt();
    rateLogger.join();
}

