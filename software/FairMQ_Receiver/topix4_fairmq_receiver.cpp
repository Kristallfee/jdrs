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
    fEventCounter(0), previous_comandoword(0), previous_dataword(0), bigcounter(false)
{
    //writetofile = new WriteToFile();

}

topix4_fairmq_receiver::~topix4_fairmq_receiver()
{
    delete(writetofile_boost);
    // writetofile->Close();
    // delete (writetofile);
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
    writetofile_boost = new TMrf_WriteToFile_Boost();
    writetofile_boost->setPathName(std::string("/private/esch/temp/"));
    writetofile_boost->openFile(atoi(FairMQDevice::fId.c_str()));
}

void topix4_fairmq_receiver::Run()
{
    LOG(INFO) << ">>>>>>> Run <<<<<<<";
    boost::thread rateLogger(boost::bind(&FairMQDevice::LogSocketRates, this));
    TMrfData_8b *tempdata;
    while ( fState == RUNNING){
        FairMQMessage* msg = fTransportFactory->CreateMessage();
        tempdata = new TMrfData_8b;

        fPayloadInputs->at(0)->Receive(msg);
        int inputSize = msg->GetSize();
        tempdata->setNumWords(inputSize);

        memcpy(reinterpret_cast<u_int8_t*>(&tempdata->regdata[0]),msg->GetData(), msg->GetSize());

        // Counter_Compare(tempdaten,previous_dataword,previous_comandoword, true, bigcounter ,writetofile, false );

        // writetofile->AppendToData(tempdaten);
        // writetofile->AppendToDataEndl();
        writetofile_boost->writeData(tempdata);

        delete msg;
    }

    rateLogger.interrupt();
    rateLogger.join();
}

