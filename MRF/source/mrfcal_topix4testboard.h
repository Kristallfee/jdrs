#ifndef MRFCAL_TOPIX4TESTBOARD_H
#define MRFCAL_TOPIX4TESTBOARD_H

#include "mrfcal.h"
#include "mrfdata_chain2ltc2604.h"
#include "mrftal_rbtopix4.h"
#include "mrfdata_topix4config.h"

class TMrfCal_ToPix4TestBoard : virtual public TMrfCal, virtual public TMrfTal_RBTopix4
{

public:

    TMrfCal_ToPix4TestBoard();

    virtual void configLTC(TMrfData_Chain2LTC2604 data) const;
    virtual void writeCommand(TMrfData_Topix4Config& data) const;

    //From TMrf_Cal
    virtual void writeToChip(const TMrfData& data) const;
    virtual void readFromChip(TMrfData_8b &data);

};

#endif // MRFCAL_TOPIX4TESTBOARD_H
