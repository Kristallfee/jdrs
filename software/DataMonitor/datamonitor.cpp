#include "datamonitor.h"
#include "mrftools.h"
#include "mrfdata_8b.h"

using mrftools::grayToBin;

DataMonitor::DataMonitor():
    _ReductionCounter(0),_ReductionRate(0)
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
    hit_map = new TH2F("HitMap","HitMap",32,-0.5,31.5,20,-0.5,19.5);
    hit_map->Draw("COLZ");

    _counter=0;

}

void DataMonitor::Run()
{
    LOG(INFO) << ">>>>>>> Run <<<<<<<";

    boost::thread rateLogger(boost::bind(&FairMQDevice::LogSocketRates, this));

    TMrfData_8b tempdaten;

    u_int64_t dataword=0;

    u_int32_t le_dataword=0; // leading edge (12 bit)
    u_int32_t te_dataword=0; // trailing edge (12 bit)
    u_int32_t pixeladdress = 0; // global pixel address (14 bit)

    while( fState == RUNNING)
    {

        FairMQMessage* msg = fTransportFactory->CreateMessage();
        fPayloadInputs->at(0)->Receive(msg);
        int inputSize = msg->GetSize();
        tempdaten.setNumWords(inputSize);

        memcpy(reinterpret_cast<u_int8_t*>(&tempdaten.regdata[0]),msg->GetData(), msg->GetSize());

        // First five 8bit words are the udp header, we are not goint to use that here. The rest are words from topix
        for(u_int i=5 ;i< tempdaten.getNumWords(); i+=5 )
        {
            dataword=0;
            // If the word is a Idle (0x00), header (0x40) or trailer (0x80) words continue. We will not use these words.
            if (( tempdaten.getWord(i)&0xc0) != 0xc0 )
            {
                continue;
            }

            if (_ReductionCounter < _ReductionRate)
            {
                _ReductionCounter++;
                continue;
            }

            _ReductionCounter=0;

            // for the data words (0xc0), combine the five 8bit packages to a 40 bit word
            for(uint j=0; j< 5 ; j++)
            {
                dataword = dataword << 8;
                dataword += tempdaten.getWord(i+j);
            }

            // dataword is a u_int64_t, empty the unused bits
            dataword = (dataword & 0x000000ffffffffff);

            // cut the information
            le_dataword = ((dataword & 0x0000000000fff000)>>12);
            te_dataword = (dataword & 0x0000000000000fff);
            pixeladdress = ((dataword & 0x0000003fff000000)>>24);

            // fill the histograms

            u_int32_t matrix_row=0, matrix_column=0;
            pixeladdressToMatrixAddress(pixeladdress, matrix_row, matrix_column);

            leading_Edge->Fill(grayToBin(le_dataword));
            trailing_Edge->Fill(grayToBin(te_dataword));
            hit_map->Fill(matrix_column, matrix_row);

        }

        if(_counter == 100)
        {
            canvas->cd(1);
            gPad->Modified();

            canvas->cd(2);
            gPad->Modified();

            canvas->Update();

            _counter=0;
        }
        _counter++;
        delete msg;
    }

    rateLogger.interrupt();
    rateLogger.join();
}
int DataMonitor::ReductionRate() const
{
    return _ReductionRate;
}

void DataMonitor::setReductionRate(int ReductionRate)
{
    _ReductionRate = ReductionRate;
}


void DataMonitor::pixeladdressToMatrixAddress(u_int32_t pixelglobaladdress, u_int32_t &matrix_row, u_int32_t &matrix_column)
{
    // Matrix: 32 columns x 20 rows

    u_int32_t double_column_address =0;
    u_int32_t double_column_side=0;
    u_int32_t pixel_address=0;

    double_column_address= ((pixelglobaladdress & 0x00003f00)>>8);
    double_column_side= ((pixelglobaladdress & 0x00000080)>>7);
    pixel_address= (pixelglobaladdress & 0x0000007F);

    u_int32_t sel = (double_column_address<<1) | (double_column_side);

    if(sel == 0)
    {
        matrix_column = 31-pixel_address;
        matrix_row = 1;
    }
    else if(sel ==1)
    {
        matrix_column = 31-pixel_address;
        matrix_row = 0;
    }
    else if(sel == 6)
    {
        matrix_column = 31-pixel_address;
        matrix_row = 19;
    }
    else if(sel == 7)
    {
        matrix_column = 31-pixel_address;
        matrix_row = 18;
    }
    else if (sel==2)
    {
        if (pixel_address <32)
        {
            matrix_column = 31-pixel_address;
            matrix_row = 9;
        }
        else if (pixel_address < 64)
        {
            matrix_column = (pixel_address-32);
            matrix_row = 6;
        }
        else if (pixel_address <96)
        {
            matrix_column = 31-(pixel_address-64);
            matrix_row = 5;
        }
        else
        {
            matrix_column = (pixel_address-96);
            matrix_row = 2;
        }
    }
    else if (sel==3)
    {
        if (pixel_address <32)
        {
            matrix_column = 31-pixel_address;
            matrix_row = 8;
        }
        else if (pixel_address < 64)
        {
            matrix_column = (pixel_address-32);
            matrix_row = 7;
        }
        else if (pixel_address <96)
        {
            matrix_column = 31-(pixel_address-64);
            matrix_row = 4;
        }
        else
        {
            matrix_column = (pixel_address-96);
            matrix_row = 3;
        }
    }
    else if (sel==4)
    {
        if (pixel_address <32)
        {
            matrix_column = 31-pixel_address;
            matrix_row = 17;
        }
        else if (pixel_address < 64)
        {
            matrix_column = (pixel_address-32);
            matrix_row = 14;
        }
        else if (pixel_address <96)
        {
            matrix_column = 31-(pixel_address-64);
            matrix_row = 13;
        }
        else
        {
            matrix_column = (pixel_address-96);
            matrix_row = 10;
        }
    }
    else if (sel==5)
    {
        if (pixel_address <32)
        {
            matrix_column = 31-pixel_address;
            matrix_row = 16;
        }
        else if (pixel_address < 64)
        {
            matrix_column = (pixel_address-32);
            matrix_row = 15;
        }
        else if (pixel_address <96)
        {
            matrix_column = 31-(pixel_address-64);
            matrix_row = 12;
        }
        else
        {
            matrix_column = (pixel_address-96);
            matrix_row = 11;
        }
    }
}
