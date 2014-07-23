#ifndef MRFCAL_TOPIX4_H
#define MRFCAL_TOPIX4_H

#include "mrftal_rbtopix4.h"
#include "mrfcal.h"
#include "mrfcal_topix4testboard.h"
#include "mrfdata_tpx4pixelmatrix.h"
#include "mrfdata_topix4command.h"
#include "iostream"


class TMrfCal_Topix4 : virtual public TMrfCal_ToPix4TestBoard
{
public:
    TMrfCal_Topix4();
    virtual ~TMrfCal_Topix4();

    virtual void configCCR(TMrfData_Topix4Config, int datalength) const;
    virtual void configPixel(TMrfData_Tpx4PixelMatrix) const;
    virtual void readCCR0(TMrfData_Topix4Config& data) const;
    virtual void readCCR1(TMrfData_Topix4Config& data) const;
    virtual void readCCR2(TMrfData_Topix4Config& data) const;
    virtual void setConfigMode();

private:
    TMrfData_ToPix4Command _command;
};

#endif // MRFCAL_TOPIX4_H
