#include "topix4_fairmq_readout.h"
#include "boost/thread.hpp"
#include "boost/bind.hpp"
#include "../helper_functions.h"
//#endif

//#include "FairMQLogger.h"

ToPix4_FairMQ_Readout::ToPix4_FairMQ_Readout() :
    previous_dataword(0), previous_comandoword(0), bigcounter(false), savedata(false), fakedatacheck(false)
{

}

ToPix4_FairMQ_Readout::~ToPix4_FairMQ_Readout()
{
    //writetofile->Close();
    delete (writetofile);
}

void ToPix4_FairMQ_Readout::Init()
{
    FairMQDevice::Init();
    writetofile->OpenFile(atoi(FairMQDevice::fId.c_str()));
    writetofile->SetIntegerBase(16);
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

    TMrfData_8b tempdaten;
    FairMQMessage* msg;
    u_int64_t dataword=0;

    while ( fState == RUNNING ) {
        _topix4control.readOutputBuffer(tempdaten,fEventSize*5);


        if(fakedatacheck){
            Counter_Compare(tempdaten, previous_dataword, previous_comandoword, savedata, bigcounter, writetofile, true);
        }
        else
        {
            for (u_int32_t i=5;i < tempdaten.getNumWords();i+=5)
            {
                dataword=0;
                for(uint j=0; j< 5 ; j++)
                {
                    dataword += tempdaten.getWord(i+j);
                    dataword = dataword >> 8;
                    std::cout << std::hex << " dataword " <<  dataword << std::endl;
                }
              //  dataword = (dataword & 0x000000ffffffffff);

                if((tempdaten.getWord(i) & 0xc000000000) == 0x0000000000 )
                {
                    std::cout << "Idle package seen " << std::hex << " dataword " <<  dataword << std::endl;
                }
                else if((tempdaten.getWord(i) & 0xc000000000) == 0x1 )
                {
                    std::cout << "header seen " << std::hex << " dataword " <<  dataword << std::endl;
                }
                else if((tempdaten.getWord(i) &  0xc000000000) == 0x2 )
                {
                    std::cout << "trailer seen "<< std::hex << " dataword " <<  dataword << std::endl;
                }
                else if((tempdaten.getWord(i) &  0xc000000000) == 0x3 )
                {
                    std::cout << "data seen " << std::hex << " dataword " <<  dataword << std::endl;
                }
            }
        }

        msg = fTransportFactory->CreateMessage(tempdaten.getNumWords());
        memcpy(msg->GetData(),reinterpret_cast<u_int8_t*>(&tempdaten.regdata[0]), tempdaten.getNumWords());

        if(tempdaten.getNumWords()>5){
            fPayloadOutputs->at(0)->Send(msg);
        }
        delete msg;
    }
    usleep(50);
    rateLogger.interrupt();
    rateLogger.join();
    //resetEventCounter.join();
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

void ToPix4_FairMQ_Readout::SetSaveData(bool value, QString path)
{
    writetofile = new WriteToFile();
    writetofile->SetPathName(path);
    savedata = value;
}

void ToPix4_FairMQ_Readout::SetFakeDataCheck(bool value)
{
    fakedatacheck = value;
}
