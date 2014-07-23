#include "topix4_fairmq_receiver.h"
#include "../../MRF/source/mrfdata.h"
#include "../../MRF/source/mrftools.h"
#include <boost/thread.hpp>

topix4_fairmq_receiver::topix4_fairmq_receiver():
    fEventSize(10000),
    fEventRate(1),
    fEventCounter(0)
{

}

topix4_fairmq_receiver::~topix4_fairmq_receiver()
{

}

void topix4_fairmq_receiver::Init()
{


}

void topix4_fairmq_receiver::Run()
{
  //  boost::thread rateLogger(boost::bind(&FairMQDevice::LogSocketRates, this));

    TMrfData tempdaten;

    while ( fState == RUNNING){
        FairMQMessage* msg = fTransportFactory->CreateMessage();

        fPayloadInputs->at(0)->Receive(msg);
        int inputSize = msg->GetSize();
        int numInput = inputSize / 40; // 40 bit per data word

        tempdaten.setNumWords(numInput);

       // tempdaten = reinterpret_cast<tempdaten>(msg->GetData());


    delete msg;

    }

    //rateLogger.interrupt();
    //rateLogger.join();
}

