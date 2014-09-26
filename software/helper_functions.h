#ifndef HELPER_FUNCTIONS_H
#define HELPER_FUNCTIONS_H

#include "mrfdata_8b.h"
#include "writetofile.h"

#endif // HELPER_FUNCTIONS_H

void Counter_Compare(TMrfData_8b tempdaten, u_int64_t &previous_dataword,u_int64_t &previous_comandoword, bool savedata, bool bigcountercheck, WriteToFile *writetofile, bool check_framecounter=false)
{
    u_int64_t dataword=0;
    u_int64_t CmdWord;
    u_int64_t le_dataword=0;
    u_int64_t te_dataword=0;
    u_int64_t previous_le_dataword=0;
    u_int64_t previous_te_dataword=0;

    dataword=0;

    if(check_framecounter){

        for(uint j=0; j< 5 ; j++)
        {
            dataword = dataword << 8;
            dataword += tempdaten.getWord(j);
        }

        CmdWord = (dataword & 0x000000000000ffff);

        if (( previous_comandoword + 1 != CmdWord) && CmdWord !=0 &&  previous_comandoword != 0xffff )
        {
            LOG(DEBUG) << std::hex << "=====ERROR IM FRAMECOUNTER ";
            LOG(DEBUG) << std::hex << "Counter Old " << previous_comandoword;
            LOG(DEBUG) << std::hex << "Counter     " << CmdWord;
        }
    }

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

        if ((dataword & 0x000000ff00000000) == 0x2200000000 or (dataword & 0x000000ff00000000) == 0x2300000000)
        {
            continue;
        }
    //    pixeladdress_dataword = ((dataword & 0x000000ffff000000)>>24);
        if(savedata)
        {
            writetofile->AppendToData(QString("%1").arg((u_int64_t)dataword,10,16,QChar('0')));
        }

        if(bigcountercheck == true)
        {
            if (previous_dataword -1 != dataword)
            {
                LOG(DEBUG) << "=====ERROR IM COUNTER." ;
                LOG(DEBUG) << "Previous Dataword " << std::hex << previous_dataword;
                LOG(DEBUG) << "Dataword          " << std::hex << dataword;

                if(savedata)
                {
                    writetofile->AppendToData(" ERROR IM COUNTER");
                }

            }
            previous_dataword = dataword;
        }
        else
        {
            previous_le_dataword = ((previous_dataword & 0x0000000000fff000)>>12);
            previous_te_dataword = (previous_dataword & 0x0000000000000fff);

            if (le_dataword!=te_dataword || le_dataword!= previous_le_dataword+1  || te_dataword!= previous_te_dataword+1)
            {
                if(previous_le_dataword==4095 && le_dataword==0)
                {
                    previous_dataword = dataword;
                    if(savedata)
                    {
                        writetofile->AppendToDataEndl();
                    }
                    continue;
                }

                if(savedata)
                {
                    writetofile->AppendToData(" ERROR IM COUNTER");
                }

                LOG(DEBUG) << "=====ERROR IM COUNTER. dataword: " << i/5 ;
                LOG(DEBUG) << "previous LE " << std::hex<< previous_le_dataword << " now LE "  << le_dataword ;
                LOG(DEBUG) << "previous TE " << std::hex << previous_te_dataword << " now TE " << te_dataword;

                LOG(DEBUG) << "NumberOfWords "  << tempdaten.getNumWords();
                LOG(DEBUG) << std::hex << "CmdWordOld " << previous_comandoword;
                LOG(DEBUG) << std::hex << "CmdWord    " << CmdWord;

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
                LOG(INFO) << "=====" ;
            }
        }
        previous_dataword = dataword;

        if(savedata)
        {
            writetofile->AppendToDataEndl();
        }
    }
   previous_comandoword = CmdWord;
}
