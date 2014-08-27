#include "mrftal_rbtopix4.h"

TMrfTal_RBTopix4::TMrfTal_RBTopix4()
{
}

TMrfTal_RBTopix4::~TMrfTal_RBTopix4()
{
}

void TMrfTal_RBTopix4::writeRemoteData(const TMrfData& data) const
{
        //std::cerr <<"data.getNumBits() "<< data.getNumBits() << std::endl;
        //std::cerr <<"data.exportBinString() "<< data.exportBinString() << std::endl;
        writeData(tpx_address::input, data);
}

void TMrfTal_RBTopix4::readRemoteData(TMrfData_8b& data)
{
        readOutputBuffer(data, data.getNumWords());
}

void TMrfTal_RBTopix4::triggerRead(const u_int32_t& triggercount, const bool& withlo) const
{
	write(tpx_address::triggercount, triggercount);
	boardCommand(tpxctrl_value::triggerwithlo, withlo);
	boardCommand(tpxctrl_value::triggerread);
}

void TMrfTal_RBTopix4::configTopixSlowReg(const TMrfData_Topix4Flags &data) const
{
	writeRegisterData(tpx_address::flags, data);
}

void TMrfTal_RBTopix4::writeLTCData(const TMrfData_Chain2LTC2604& data) const
{
        writeData(tpx_address::ltcconfig,data);
        //boardCommand(tpxctrl_value::ltcconfig);
}

void TMrfTal_RBTopix4::startSerializer(const u_int32_t& count) const
{
        write(tpx_address::inputcount, count);
        boardCommand(tpxctrl_value::topix4config);
}


