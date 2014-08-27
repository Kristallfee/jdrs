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

}

void DataMonitor::Run()
{
    LOG(INFO) << ">>>>>>> Run <<<<<<<";

    boost::thread rateLogger(boost::bind(&FairMQDevice::LogSocketRates, this));

    TMrfData_8b tempdaten;

    u_int64_t dataword=0;
    long int previous_le_dataword=0;
    long int previous_te_dataword=0;

    long int le_dataword=0;
    long int te_dataword=0;

    while( fState == RUNNING)
    {
        FairMQMessage* msg = fTransportFactory->CreateMessage();
        fPayloadInputs->at(0)->Receive(msg);
        int inputSize = msg->GetSize();
        tempdaten.setNumWords(inputSize);

        memcpy(reinterpret_cast<u_int8_t*>(&tempdaten.regdata[0]),msg->GetData(), msg->GetSize());

        for(u_int i=0 ;i< tempdaten.getNumWords(); i+=5 )
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


            if (le_dataword!=te_dataword)
            {
                LOG(INFO) << "LE != TE. dataword: " << i/5 ;
                LOG(INFO) << "LE " <<  le_dataword;
                LOG(INFO) << "TE " << te_dataword ;
            }

            if (le_dataword!= previous_le_dataword+1 || te_dataword!= previous_te_dataword+1)
            {
                if(previous_le_dataword==4095 && le_dataword==0)
                {
                    previous_le_dataword = le_dataword;
                    previous_te_dataword = te_dataword;
                    continue;
                }

                LOG(INFO) << "=====ERROR IM COUNTER. dataword: " << i/5 ;
                LOG(INFO) << "previous LE " << previous_le_dataword << " now LE "  << le_dataword ;
                LOG(INFO) << "previous TE "  << previous_te_dataword << " now TE " << te_dataword;

                LOG(INFO) << "NumberOfWords "  << tempdaten.getNumWords();

                std::cout << std::setfill('0') << std::setw(2);

                if(i>9)
                {
                    std::cout << std::setfill('0') << std::setw(2)<< std::hex <<  (u_int16_t)(tempdaten.getWord(i-10))<< (u_int16_t)(tempdaten.getWord(i-9))<< (u_int16_t)(tempdaten.getWord(i-8)) << (u_int16_t)(tempdaten.getWord(i-7))<<  (u_int16_t)(tempdaten.getWord(i-6))  << std::endl;
                }
                else
                {
                    std::cout << "First Dataword in package" << std::endl;
                }

                if(i>4)
                {
                    std::cout << std::setfill('0') << std::setw(2)<< std::hex <<  (u_int16_t)(tempdaten.getWord(i-5))<< (u_int16_t)(tempdaten.getWord(i-4))<< (u_int16_t)(tempdaten.getWord(i-3)) << (u_int16_t)(tempdaten.getWord(i-2))<<  (u_int16_t)(tempdaten.getWord(i-1))  << std::endl;
                }
                else
                {
                    std::cout << "First Dataword in package" << std::endl;
                }

                std::cout << std::hex << "dataword " <<  dataword << std::endl;
                if(i< tempdaten.getNumWords()-9 && tempdaten.getNumWords()>9 )
                {
                    std::cout<< std::setfill('0') << std::setw(2) << std::hex <<  static_cast<int>(tempdaten.getWord(i+5))<< static_cast<int>(tempdaten.getWord(i+6))<< static_cast<int>(tempdaten.getWord(i+7)) << static_cast<int>(tempdaten.getWord(i+8))<<  static_cast<int>(tempdaten.getWord(i+9))  << std::endl;
                }
                else
                {
                    std::cout << "Last Dataword in package" << std::endl;
                }

                if(i< tempdaten.getNumWords()-14 && tempdaten.getNumWords()>14 )
                {
                    std::cout << std::setfill('0') << std::setw(2)<< std::hex <<  static_cast<int>(tempdaten.getWord(i+10))<< static_cast<int>(tempdaten.getWord(i+11))<< static_cast<int>(tempdaten.getWord(i+12)) << static_cast<int>(tempdaten.getWord(i+13))<<  static_cast<int>(tempdaten.getWord(i+14))  << std::endl;
                }
                else
                {
                    std::cout << "Last Dataword in package" << std::endl;
                }
                LOG(INFO) << "=====" << te_dataword;

            }
            previous_le_dataword = le_dataword;
            previous_te_dataword = te_dataword;
        }

        canvas->cd(0);
        gPad->Modified();

        canvas->cd(1);
        gPad->Modified();

        canvas->Update();

        delete msg;
    }

    rateLogger.interrupt();
    rateLogger.join();
}
