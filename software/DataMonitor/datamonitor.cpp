#include "datamonitor.h"

#include "mrfdata_8b.h"

DataMonitor::DataMonitor()
{
}

DataMonitor::~DataMonitor()
{

}

void DataMonitor::Init()
{
    FairMQDevice::Init();
    canvas = new TCanvas("DataMonitor","DataMonitor",700, 500);
    canvas->Divide(2,2);
    canvas->Show();

    canvas->cd(1);
    leading_Edge = new TH1F("LeadingEdge","LeadingEdge",4096,-0.5,4095.5);
    leading_Edge->Draw();

    canvas->cd(2);
    trailing_Edge = new TH1F("TrailingEdge","TrailingEdge",4096,-0.5,4095.5);
    trailing_Edge->Draw();

    canvas->cd(3);
    pixel_position = new TH2F("PixelPosition","PixelPosition",32,-0.5,31.5,20,-0.5,19.5);
    pixel_position->Draw();

    counter=0;

}

void DataMonitor::Run()
{
    LOG(INFO) << ">>>>>>> Run <<<<<<<";

    boost::thread rateLogger(boost::bind(&FairMQDevice::LogSocketRates, this));

    TMrfData_8b tempdaten;

    u_int64_t dataword=0;

    long int le_dataword=0;
    long int te_dataword=0;

    while( fState == RUNNING)
    {

        FairMQMessage* msg = fTransportFactory->CreateMessage();
        fPayloadInputs->at(0)->Receive(msg);
        int inputSize = msg->GetSize();
        tempdaten.setNumWords(inputSize);

        memcpy(reinterpret_cast<u_int8_t*>(&tempdaten.regdata[0]),msg->GetData(), msg->GetSize());

        for(u_int i=5 ;i< tempdaten.getNumWords(); i+=5 )
        {
            dataword=0;

            for(uint j=0; j< 5 ; j++)
            {
                dataword = dataword << 8;
                dataword += tempdaten.getWord(i+j);
            }
            dataword = (dataword & 0x000000ffffffffff);

            le_dataword = ((dataword & 0x0000000000fff000)>>12);
            te_dataword = (dataword & 0x0000000000000fff);

            leading_Edge->Fill(le_dataword);
            trailing_Edge->Fill(te_dataword);

        }

        if(counter == 100)
        {
          //  canvas->cd(1);
          //  gPad->Modified();

          //  canvas->cd(2);
            gPad->Modified();

            canvas->Update();

            counter=0;
        }
            counter++;
        delete msg;
    }

    rateLogger.interrupt();
    rateLogger.join();
}
