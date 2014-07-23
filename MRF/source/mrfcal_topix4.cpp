#include "mrfcal_topix4.h"

TMrfCal_Topix4::TMrfCal_Topix4()
{
}

TMrfCal_Topix4::~TMrfCal_Topix4()
{
}

void TMrfCal_Topix4::configCCR(TMrfData_Topix4Config data, int datalength) const
{
        writeRemoteData(data);
//        std::cerr <<"data.getNumBits() "<< data.getNumBits() << std::endl;
//        std::cerr <<"data.exportBinString() "<< data.exportBinString() << std::endl;
//        boardCommand(tpxctrl_value::topix3config);
        startSerializer(datalength);
        read(tpx_address::sdataout);
        read(tpx_address::sdataout);
        read(tpx_address::sdataout);
}

void TMrfCal_Topix4::configPixel(TMrfData_Tpx4PixelMatrix) const
{
    std::cout << "function TMrfCal_Topix4::configPixel not implemented yet! " << std::endl;

}

void TMrfCal_Topix4::readCCR0(TMrfData_Topix4Config& data) const
{
        data.setCommand(topix4_ccrnumber::ccr0,topix4_command::readdataccr0);
        data.assemble();
        write(tpx_address::input,data.getWord(0));
        data.setCommand(topix4_ccrnumber::ccr0,topix4_command::nooperation);
        data.assemble();
        write(tpx_address::input,data.getWord(0));
        boardCommand(tpxctrl_value::topix4config);
        data.setWord(0,read(tpx_address::sdataout));
        data.setWord(0,read(tpx_address::sdataout));
}

void TMrfCal_Topix4::readCCR1(TMrfData_Topix4Config& data) const
{
        data.setCommand(topix4_ccrnumber::ccr1,topix4_command::readdataccr1);
        data.assemble();
        write(tpx_address::input,data.getWord(1));
        data.setCommand(topix4_ccrnumber::ccr1, topix4_command::nooperation);
        data.assemble();
        write(tpx_address::input, data.getWord(1));
        boardCommand(tpxctrl_value::topix4config);
        data.setWord(1,read(tpx_address::sdataout));
        data.setWord(1,read(tpx_address::sdataout));
}

void TMrfCal_Topix4::readCCR2(TMrfData_Topix4Config& data) const
{
    data.setCommand(topix4_ccrnumber::ccr2,topix4_command::readdataccr2);
    data.assemble();
    write(tpx_address::input,data.getWord(2));
    data.setCommand(topix4_ccrnumber::ccr2,topix4_command::nooperation);
    data.assemble();
    write(tpx_address::input,data.getWord(2));
    boardCommand(tpxctrl_value::topix4config);
    data.setWord(2,read(tpx_address::sdataout));
    data.setWord(2,read(tpx_address::sdataout));
}

void TMrfCal_Topix4::setConfigMode()
{
    _command.setOperationCode(topix4operationcode::configmodeoperation);
    _command.assemble();
    write(tpx_address::input,_command.getWord(2));
    boardCommand(tpxctrl_value::topix4config);

}
