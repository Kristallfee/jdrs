#ifndef HELPER_FUNCTIONS_H
#define HELPER_FUNCTIONS_H

#include "mrfdata_8b.h"

#endif // HELPER_FUNCTIONS_H

void Counter_Compare(TMrfData_8b tempdaten, u_int64_t &CmdWordOld, u_int64_t &previous_le_dataword, u_int64_t &previous_te_dataword )
{
    u_int64_t dataword=0;
    u_int64_t CmdWord;
  //  long int previous_le_dataword=0;
 //   long int previous_te_dataword=0;

    u_int64_t le_dataword=0;
    u_int64_t te_dataword=0;
    u_int64_t pixeladdress_dataword=0;


    dataword=0;

    for(uint j=0; j< 5 ; j++)
    {
        dataword = dataword << 8;
        dataword += tempdaten.getWord(j);
    }

    CmdWord = (dataword & 0x000000000000ffff);

    if ((CmdWordOld + 1 != CmdWord) && CmdWord !=0 && CmdWordOld != 0xffff )
    {
         LOG(INFO) << std::hex << "=====ERROR IM FRAMECOUNTER ";
         LOG(INFO) << std::hex << "CmdWordOld " << CmdWordOld;
         LOG(INFO) << std::hex << "CmdWord    " << CmdWord;
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
        pixeladdress_dataword = ((dataword & 0x000000ffff000000)>>24);

       // std::cout <<std::hex <<  "LE:" << le_dataword << " TE: " << te_dataword << std::endl;

        if (le_dataword!=te_dataword || le_dataword!= previous_le_dataword+1  || te_dataword!= previous_te_dataword+1)
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
            LOG(INFO) << std::hex << "CmdWordOld " << CmdWordOld;
            LOG(INFO) << std::hex << "CmdWord    " << CmdWord;


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
        CmdWordOld = CmdWord;


}
