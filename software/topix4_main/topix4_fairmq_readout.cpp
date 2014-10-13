#include "topix4_fairmq_readout.h"
#include "boost/thread.hpp"
#include "boost/bind.hpp"
#include "../helper_functions.h"
#include "boost/archive/binary_oarchive.hpp"
#include "boost/archive/binary_iarchive.hpp"
#include "boost/serialization/binary_object.hpp"
#include "boost/archive/text_oarchive.hpp"

//#endif

//#include "FairMQLogger.h"

void FreeTempdata(void* data, void* hint)
{
    delete (data);
}

ToPix4_FairMQ_Readout::ToPix4_FairMQ_Readout() :
    previous_dataword(0), previous_comandoword(0), bigcounter(false), savedata(false), fakedatacheck(false)
{

}

ToPix4_FairMQ_Readout::~ToPix4_FairMQ_Readout()
{
    //writetofile->Close();
    //delete (writetofile);
    //  writetofile_boost->closeFile();
    delete(writetofile_boost);
}

void ToPix4_FairMQ_Readout::Init()
{
    FairMQDevice::Init();
    writetofile_boost = new TMrf_WriteToFile_Boost();
    writetofile_boost->openFile(atoi(FairMQDevice::fId.c_str()));
    // writetofile->OpenFile(atoi(FairMQDevice::fId.c_str()));
    // writetofile->SetIntegerBase(16);
    // ofs.open("/private/esch/temp/test.txt",std::ios::binary);
}

int ToPix4_FairMQ_Readout::OpenASICConnection(QString connectionparamter)
{
    _topix4control.openDevice(connectionparamter.toLatin1() );
    return _topix4control.getLastError();
}

int ToPix4_FairMQ_Readout::CloseASICConnection()
{
    _topix4control.closeDevice();
    return _topix4control.getLastError();
}

void ToPix4_FairMQ_Readout::Run()
{
    LOG(INFO) << ">>>>>>> Run <<<<<<<";

    boost::thread rateLogger(boost::bind(&FairMQDevice::LogSocketRates, this));
    //  boost::thread resetEventCounter(boost::bind(&O2FLPex::ResetEventCounter, this));

    TMrfData_8b *tempdata;
    FairMQMessage* msg;
    //    u_int64_t dataword=0;
    //    u_int64_t header=0;
    //    bool header_print=false;
    //    bool header_printed=false;

    // boost::archive::binary_oarchive oa(ofs);

    while ( fState == RUNNING )
    {
        tempdata = new TMrfData_8b;
        int words_read = _topix4control.readOutputBuffer(*tempdata,fEventSize*5);

        //std::cout << " wordsread " << words_read << std::endl;

        if(savedata==true){
            //   writetofile->AppendToData(*tempdata);
            // writetofile->AppendToDataEndl();
            writetofile_boost->writeData(tempdata);
        }

        // boost serializer
        //  oa << tempdata;

        //        if(fakedatacheck){
        //            Counter_Compare(tempdaten, previous_dataword, previous_comandoword, savedata, bigcounter, writetofile, true);
        //        }
        //        else
        //        {

        //        for (u_int32_t i=5;i < tempdaten.getNumWords();i+=5)
        //        {
        //            dataword=0;
        //            for(uint j=0; j< 5 ; j++)
        //            {
        //                dataword = dataword << 8;
        //                dataword += tempdaten.getWord(i+j);
        //            }

        //            if(savedata==true){
        //                writetofile->AppendToData(dataword);
        //            }

        //            if((dataword & 0xc000000000) == 0x0000000000 )
        //            {
        //                //std::cout << "Idle package seen " << std::hex << " dataword " <<  dataword << std::endl;
        //            }
        //            else if((dataword & 0xc000000000) == 0x4000000000 )
        //            {
        //                // std::cout << "header seen " << std::hex << " dataword " <<  dataword << " Chip Address " << std::dec << ((dataword & 0x3ffc000000)>>26) << " Frame counter " << ((dataword & 0x0003fc0000)>>18) << " not used " << std::hex << ((dataword & 0x000003ffc0)>>6) << std::dec << " ECC " << (dataword & 0x000000003f)  << std::endl;
        //                header=dataword;
        //            }
        //            else if((dataword &  0xc000000000) == 0x8000000000)
        //            {
        //                if(header_printed==true)
        //                {
        //                    std::cout << "trailer seen "<< std::hex << " dataword " <<  dataword << " Number of Events " <<   std::dec <<  ((dataword & 0x3fffc00000)>>22) << " frame crc " <<   ((dataword & 0x00003fffc0)>>6) << " ECC " << (dataword & 0x000000003f) <<  std::endl;
        //                }
        //                //trailer=dataword;
        //                header_printed=false;
        //                header_print=false;
        //            }
        //            else if((dataword &  0xc000000000) == 0xc000000000 )
        //            {
        //                header_print=true;
        //                if(header_print==true && header_printed==false)
        //                {
        //                    std::cout << "header seen " << std::hex << " dataword " <<  header << " Chip Address " << std::dec << ((header & 0x3ffc000000)>>26) << " Frame counter " << ((header & 0x0003fc0000)>>18) << " not used " << std::hex << ((header & 0x000003ffc0)>>6) << std::dec << " ECC " << (header & 0x000000003f)  << std::endl;
        //                    header_printed=true;
        //                    header_print=false;
        //                }
        //                std::cout << "data seen " << std::hex << " dataword " <<  dataword <<  std::dec << " Address "<<  ((dataword & 0x3fff000000)>>24) << " Leading Edge " << std::dec <<  ((dataword & 0x0000000000fff000)>>12) << " Trailing Edge " << (dataword & 0x0000000000000fff) << " TOT " << (dataword & 0x0000000000000fff) - ((dataword & 0x0000000000fff000)>>12)<<  std::endl;
        //            }
        //            //            }
        //        }

        //    msg = fTransportFactory->CreateMessage(tempdata->getNumWords());
        //    memcpy(msg->GetData(),reinterpret_cast<u_int8_t*>(&tempdata->regdata[0]), tempdata->getNumWords());

        //        for(int i =0;i < tempdata.getNumWords();i++)
        //        {
        //            std::cout << "i " << i << " tempdata.getWord(i) " <<std::hex<<   (int)  tempdata.getWord(i) << std::endl;
        //        }


        msg = fTransportFactory->CreateMessage(reinterpret_cast<u_int8_t*>(&tempdata->regdata[0]),tempdata->getNumWords(),FreeTempdata);

        //        for(int i =0;i < tempdata.getNumWords();i++)
        //        {
        //            std::cout << "i " << i << " tempdata.getWord(i) " <<std::hex<<   (int)tempdata.getWord(i) << std::endl;
        //        }

        //  std::cout << "Sizeof 2 " << sizeof(tempdata) << std::endl;

        if(tempdata->getNumWords()>5){
            fPayloadOutputs->at(0)->Send(msg);
        }
        delete msg;
    }
    // usleep(100);
    rateLogger.interrupt();
    rateLogger.join();
    //resetEventCounter.join();

    FairMQDevice::Shutdown();
    boost::lock_guard<boost::mutex> lock(fRunningMutex);
    fRunningFinished = true;
    fRunningCondition.notify_one();
}



void ToPix4_FairMQ_Readout::SetProperty(const int key, const string& value, const int slot/*= 0*/)
{
    switch (key) {
    default:
        FairMQDevice::SetProperty(key, value, slot);
        break;
    }
}

string ToPix4_FairMQ_Readout::GetProperty(const int key, const string& default_/*= ""*/, const int slot/*= 0*/)
{
    switch (key) {
    default:
        return FairMQDevice::GetProperty(key, default_, slot);
    }
}

void ToPix4_FairMQ_Readout::SetProperty(const int key, const int value, const int slot/*= 0*/)
{
    switch (key) {
    case EventSize:
        fEventSize = value;
        break;
    case EventRate:
        fEventRate = value;
        break;
    default:
        FairMQDevice::SetProperty(key, value, slot);
        break;
    }
}

int ToPix4_FairMQ_Readout::GetProperty(const int key, const int default_/*= 0*/, const int slot/*= 0*/)
{
    switch (key) {
    case EventSize:
        return fEventSize;
    case EventRate:
        return fEventRate;
    default:
        return FairMQDevice::GetProperty(key, default_, slot);
    }
}

void ToPix4_FairMQ_Readout::SetOutputWindow(QTextEdit *window)
{
    _window = window;
}

void ToPix4_FairMQ_Readout::SetBigCounter(bool value)
{
    bigcounter = value;
}

void ToPix4_FairMQ_Readout::SetSaveData(bool value, std::string path)
{

    writetofile_boost->setPathName(path);
    savedata = value;
    // writetofile = new WriteToFile();
    // writetofile->SetPathName(path);
    // savedata = value;
}

void ToPix4_FairMQ_Readout::SetFakeDataCheck(bool value)
{
    fakedatacheck = value;
}
