#include "topix4_fairmq_receiver.h"
#include "mrfdata_8b.h"
#include "mrftools.h"
#include <boost/thread.hpp>
#include "FairMQLogger.h"
#include "helper_functions.h"
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <limits.h>

topix4_fairmq_receiver::topix4_fairmq_receiver():
    fEventSize(10000),
    fEventRate(1),
    fEventCounter(0), CmdWordOld(0),previous_le_dataword(0), previous_te_dataword(0)
{

}

topix4_fairmq_receiver::~topix4_fairmq_receiver()
{
    writetofile.Close();
}

void topix4_fairmq_receiver::Init()
{
    FairMQDevice::Init();
    writetofile.OpenFile(atoi(FairMQDevice::fId.c_str()));
    writetofile.SetIntegerBase(16);
}

void topix4_fairmq_receiver::Run()
{
    LOG(INFO) << ">>>>>>> Run <<<<<<<";

    boost::thread rateLogger(boost::bind(&FairMQDevice::LogSocketRates, this));

    TMrfData_8b tempdaten;

//    u_int64_t dataword=0;
//    //long int previous_dataword=0;
//    long int previous_le_dataword=0;
//    long int previous_te_dataword=0;

//    long int le_dataword=0;
//    long int te_dataword=0;

    while ( fState == RUNNING){
        FairMQMessage* msg = fTransportFactory->CreateMessage();

        fPayloadInputs->at(0)->Receive(msg);
        int inputSize = msg->GetSize();
        //  LOG(INFO) << "Number of bytes " << inputSize << " Number of Data Words " <<  inputSize/8;
        tempdaten.setNumWords(inputSize);



        memcpy(reinterpret_cast<u_int8_t*>(&tempdaten.regdata[0]),msg->GetData(), msg->GetSize());


        Counter_Compare(tempdaten, CmdWordOld, previous_le_dataword, previous_te_dataword);


        for(u_int i=0 ;i< tempdaten.getNumWords(); i+=5 )
        {
          //  dataword=0;

            for(uint j=0; j< 5 ; j++)
            {
                dataword = dataword << 8;
                dataword += tempdaten.getWord(i+j);
            }
            dataword = (dataword & 0x000000ffffffffff);

            le_dataword = ((dataword & 0x0000000000fff000)>>12);
            te_dataword = (dataword & 0x0000000000000fff);

            writetofile.AppendToData(QString("%1").arg((u_int64_t)dataword,10,16,QChar('0')));
            writetofile.AppendToData(" - ");
            writetofile.AppendToData(le_dataword);
            writetofile.AppendToData(" ");
            writetofile.AppendToData(te_dataword);
            writetofile.AppendToData(" ");



//            if (le_dataword!=te_dataword || le_dataword!= previous_le_dataword+1 || te_dataword!= previous_te_dataword+1)
//            {
//                if(previous_le_dataword==4095 && le_dataword==0)
//                {
//                    previous_le_dataword = le_dataword;
//                    previous_te_dataword = te_dataword;
//                    continue;
//                }

//                writetofile.AppendToData(" ERROR IM COUNTER");

//                LOG(INFO) << "=====ERROR IM COUNTER. dataword: " << i/5 ;
//                LOG(INFO) << "previous LE " << previous_le_dataword << " now LE "  << le_dataword ;
//                LOG(INFO) << "previous TE "  << previous_te_dataword << " now TE " << te_dataword;

//                LOG(INFO) << "NumberOfWords "  << tempdaten.getNumWords();

//                std::cout << std::setfill('0') << std::setw(2);

//                if(i>9)
//                {
//                    std::cout << std::setfill('0') << std::setw(2)<< std::hex <<  (u_int16_t)(tempdaten.getWord(i-10))<< (u_int16_t)(tempdaten.getWord(i-9))<< (u_int16_t)(tempdaten.getWord(i-8)) << (u_int16_t)(tempdaten.getWord(i-7))<<  (u_int16_t)(tempdaten.getWord(i-6))  << std::endl;
//                }
//                else
//                {
//                    std::cout << "First Dataword in package" << std::endl;
//                }

//                if(i>4)
//                {
//                    std::cout << std::setfill('0') << std::setw(2)<< std::hex <<  (u_int16_t)(tempdaten.getWord(i-5))<< (u_int16_t)(tempdaten.getWord(i-4))<< (u_int16_t)(tempdaten.getWord(i-3)) << (u_int16_t)(tempdaten.getWord(i-2))<<  (u_int16_t)(tempdaten.getWord(i-1))  << std::endl;
//                }
//                else
//                {
//                    std::cout << "First Dataword in package" << std::endl;
//                }


//                std::cout << std::hex << "dataword " <<  dataword << std::endl;
//                if(i< tempdaten.getNumWords()-9 && tempdaten.getNumWords()>9 )
//                {

//                    std::cout<< std::setfill('0') << std::setw(2) << std::hex <<  static_cast<int>(tempdaten.getWord(i+5))<< static_cast<int>(tempdaten.getWord(i+6))<< static_cast<int>(tempdaten.getWord(i+7)) << static_cast<int>(tempdaten.getWord(i+8))<<  static_cast<int>(tempdaten.getWord(i+9))  << std::endl;

//                }
//                else
//                {
//                    std::cout << "Last Dataword in package" << std::endl;
//                }

//                if(i< tempdaten.getNumWords()-14 && tempdaten.getNumWords()>14 )
//                {
//                    std::cout << std::setfill('0') << std::setw(2)<< std::hex <<  static_cast<int>(tempdaten.getWord(i+10))<< static_cast<int>(tempdaten.getWord(i+11))<< static_cast<int>(tempdaten.getWord(i+12)) << static_cast<int>(tempdaten.getWord(i+13))<<  static_cast<int>(tempdaten.getWord(i+14))  << std::endl;

//                }
//                else
//                {
//                    std::cout << "Last Dataword in package" << std::endl;
//                }
//                LOG(INFO) << "=====" << te_dataword;

//                if(inputSize==1 && dataword==0xffffffffff)
//                {
//                    writetofile.Close();
//                    writetofile.OpenFile(atoi(FairMQDevice::fId.c_str()));
//                    writetofile.SetIntegerBase(16);
//                }

            }
            previous_le_dataword = le_dataword;
            previous_te_dataword = te_dataword;

            writetofile.AppendToDataEndl();
        }




    delete msg;

    }

    rateLogger.interrupt();
    rateLogger.join();
}

