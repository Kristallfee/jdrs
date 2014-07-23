#include "topix4_fairmq_readout.h"

//#ifndef Q_MOC_RUN  // workaround for issue with boost and qt < Qt5
//#include <boost/thread.hpp>
//#include <boost/bind.hpp>
//#endif

//#include "FairMQLogger.h"


ToPix4_FairMQ_Readout::ToPix4_FairMQ_Readout()
{
}

ToPix4_FairMQ_Readout::~ToPix4_FairMQ_Readout()
{
}

void ToPix4_FairMQ_Readout::Init()
{

    FairMQDevice::Init();

}

int ToPix4_FairMQ_Readout::OpenASICConnection(QString connectionparamter)
{
  //  QString _connectionParameter = QString("%1,%2,%3,%4")
  //          .arg(ownIP)
   //         .arg(ownPort)
   //         .arg(remoteIP)
  //          .arg(remotePort);
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
   // LOG(INFO) << ">>>>>>> Run <<<<<<<";

  //  boost::thread rateLogger(boost::bind(&FairMQDevice::LogSocketRates, this));
  //  boost::thread resetEventCounter(boost::bind(&O2FLPex::ResetEventCounter, this));

    TMrfData_8b tempdaten;
    FairMQMessage* msg;

    while ( fState == RUNNING ) {

        _topix4control.readOutputBuffer(tempdaten,fEventSize*5);
        std::cout << "get no of words: " <<  tempdaten.getNumWords() << std::endl;  // a word is a 8 bit unit
        std::cout << "get no of data words: " <<  tempdaten.getNumWords()/5 << std::endl; // one data word is made of 5 words (=40 bit)
        std::cout << "no of bits : " <<  tempdaten.getNumWords()*8 << std::endl;

       /* FairMQMessage* msg = fTransportFactory->CreateMessage(500);  // reserve space in byte
        for (int i=0; i<tempdaten.getNumWords() ; i+=500)  // send per fairmq message 100 data words
        {
            memcpy(msg->GetData(),reinterpret_cast<u_int8_t*>(&tempdaten.regdata[i]), tempdaten.getNumWords()*500);

        }
        */


        msg = fTransportFactory->CreateMessage(tempdaten.getNumWords()*5);
        memcpy(msg->GetData(),reinterpret_cast<u_int8_t*>(&tempdaten.regdata[0]), tempdaten.getNumWords()*5);

        std::cout << "copy of data done" << std::endl;

        if(tempdaten.getNumWords()!=0){
        fPayloadOutputs->at(0)->Send(msg);

        }

        delete msg;
    }
 //   rateLogger.interrupt();
//    resetEventCounter.interrupt();

 //   rateLogger.join();
 //   resetEventCounter.join();

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
