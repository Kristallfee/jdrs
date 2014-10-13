#include <iostream>
#include <fstream>
#include "mrfdata_8b.h"
#include "boost/archive/binary_oarchive.hpp"
#include "boost/archive/binary_iarchive.hpp"
#include "boost/serialization/binary_object.hpp"


int main(int argc, char* argv[])
{
    std::cout << "Hello World! Welcome to the ToPix4 boost serializer data converter!" << std::endl;
    u_int64_t dataword=0;

    TMrfData_8b *tempdata;
    tempdata = new TMrfData_8b;
    std::ifstream is(argv[1], std::ios::binary);

    if(is.is_open()!= true)
    {
        std::cout << "No inputfile found! " << std::endl;
        return -1;
    }
    else
    {
        std::cout << "Inputfile found! " << std::endl;

    }

    while(is)
    {

        boost::archive::binary_iarchive iar(is);
        iar >> tempdata;

        for (u_int32_t i=0;i < tempdata->getNumWords();i+=5)
        {
            dataword=0;
            for(uint j=0; j< 5 ; j++)
            {
                dataword = dataword << 8;
                dataword += tempdata->getWord(i+j);
            }
            if(i==0)
            {
                std::cout << std::dec << "dataword No "<< i/5<< "/"<< tempdata->getNumWords()/5 << ": "<<std::hex << dataword << std::endl;
            }
        }
        std::cout << "Finish with message " << std::endl;
    }


    return 0;
}

