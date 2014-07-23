#include "mrfcal_topix4testboard.h"
#include "mrfdata_ltc.h"

TMrfCal_ToPix4TestBoard::TMrfCal_ToPix4TestBoard()
: TMrfCal()
{
}

void TMrfCal_ToPix4TestBoard::configLTC(TMrfData_Chain2LTC2604 data) const
{
       std::map<std::string, TConfItem>::const_iterator iterDAC;
       std::map<const std::string, std::map<std::string, TConfItem> >::const_iterator iterLTC;
       for(iterDAC = data.getDACIteratorBegin("LTC1"); iterDAC !=data.getDACIteratorEnd("LTC1"); ++iterDAC){
           for(iterLTC = data.getLTCIteratorBegin(); iterLTC!= data.getLTCIteratorEnd(); ++iterLTC){
               if(data.getDACActivated(iterLTC->first, iterDAC->first)==1)
               {
                   data.setCommand(iterLTC->first,ltc2604::writeupdate);
               }
               else
               {
                   data.setCommand(iterLTC->first ,ltc2604::powerdown);
               }
           }
           data.assembleDAC(iterDAC->first);
           writeLTCData(data);
       }
       boardCommand(tpxctrl_value::ltcconfig);
}

void TMrfCal_ToPix4TestBoard::writeToChip(const TMrfData& data) const
{
        writeRemoteData(data);
        boardCommand(tpxctrl_value::topix4config);
        read(tpx_address::sdataout);
}

void TMrfCal_ToPix4TestBoard::readFromChip(TMrfData_8b& data)
{
	triggerRead(data.getNumWords(), true);
	readRemoteData(data);
}

void TMrfCal_ToPix4TestBoard::writeCommand(TMrfData_Topix4Config &data) const
{
        data.assemble();
        write(tpx_address::input,data.getWord(0));
        boardCommand(tpxctrl_value::topix4config);
}
