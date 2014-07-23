#ifndef MRFDATA_TOPIX4COMMAND_H
#define MRFDATA_TOPIX4COMMAND_H

#include "mrfdataadv1d.h"

namespace topix4operationcode {
static const u_int32_t nooperation = 0;
static const u_int32_t normaloperation = 1;
static const u_int32_t configmodeoperation = 2;
static const u_int32_t columnselection = 3;
static const u_int32_t writepixelconfiguration = 4;
static const u_int32_t readpixelconfiguration = 5;
static const u_int32_t movetonextpixel = 7;
static const u_int32_t writeccr0configuration = 33;
static const u_int32_t writeccr1configuration = 34;
static const u_int32_t writeccr2configuration = 36;
static const u_int32_t writeccr3configuration = 40;
static const u_int32_t readccr0configuration = 49;
static const u_int32_t readccr1configuration = 50;
static const u_int32_t readccr2configuration = 52;
static const u_int32_t readccr3configuration = 56;
}

class TMrfData_ToPix4Command : virtual public TMrfDataAdv1D
{
public:
    TMrfData_ToPix4Command(const u_int32_t& blocklength = bitsinablock, const u_int32_t& defaultindex = 0, const u_int32_t& defaultstreamoffset = 0, const u_int32_t& defaultvalueoffset = 0, const bool& defaultreverse = false, const bool& defaultstreamreverse = false);

    virtual void initMaps();
    virtual void assemble();
    virtual void setOperationCode(u_int32_t);
    virtual void setData(u_int32_t);
};

#endif // MRFDATA_TOPIX4COMMAND_H
