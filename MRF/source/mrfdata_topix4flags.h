/*============================================================*/
/* mrfdata_topix4flags.h                                      */
/* MVD Readout Framework Data Storage                         */
/* Provides Access to ToPix4 Control Flags.                   */
/*                                                  S.U. Esch */
/*============================================================*/


#ifndef MRFDATA_TOPIX4FLAGS_H
#define MRFDATA_TOPIX4FLAGS_H

#include "mrfdataadv1d.h"

class TMrfData_Topix4Flags : virtual public TMrfDataAdv1D
{
public:
    TMrfData_Topix4Flags(const u_int32_t& blocklength = bitsinablock, const u_int32_t& defaultindex = 0, const u_int32_t& defaultstreamoffset = 0, const u_int32_t& defaultvalueoffset = 0, const bool& defaultreverse = false, const bool& defaultstreamreverse = false);


    //From TMrfDataAdvBase
    virtual void initMaps();

};

#endif // MRFDATA_TOPIX4FLAGS_H
